# app/workers/game_worker.rb

# TODO
#   Report time info back to the client
#   There seems to be a need for an association model between player and match.
#   It would save stuff such as the player's piece, times and moves.
#   Get to it together with Ryan sometime

class GameWorker
  include Sidekiq::Worker
  
  def perform(match_id)
    @match = Match.find(match_id)

    load_js_context
    build_communication_channel    
    build_duelers # Currently sets challenger as second player

    @player, @opponent = @opponent, @player if @match.turn
    
    while @match.result == "open" do
      p ["Turn: ", @player[:side]]
      p ["time_left", @player[:time_left]]
      fetch_move
      return timeout if @move.empty? || @player[:time_left] < 0
      return illegal unless @ttt.isValidMove(@match.state, @move)
      make_move
      publish_move
      
      game_over = @ttt.checkForWinner(@match.state, @player[:side])      
      if game_over == @player[:side]
        return player_victory 
      elsif game_over == "T"
        return tie
      end
      
      @player, @opponent = @opponent, @player
    end
  end

  private

  # Load a JavaScript context
  def load_js_context
    @cxt = V8::Context.new
    @cxt.load("#{Rails.root.to_s}/games/ttt/game.js")
    @ttt = @cxt[:ttt]
  end

  def build_communication_channel
    @redis = Redis.new(:url => ENV['REDISTOGO_URL'])
    @redis_channel = @match.id.to_s
  end

  # Takes a player object and builds a map of required data
  def build_player(player)
    location = player.location.current_path.split('/')
    script = location[-1][0...-3]
    location = location[0...-1].join('/')
    time_left = @match.time_alloted
    
    return {player: player, location: location, script: script,
            time_left: time_left}    
  end

  # Simply sets the initial players for the game
  def build_duelers
    @player = build_player(@match.mario)
    @player[:side] = 'x'
    @opponent = build_player(@match.luigi)
    @opponent[:side] = 'o'
  end

  # Get the move from the relevant script and time it
  def fetch_move
    cmd = "python #{Rails.root.to_s}/runner.py #{@player[:location]} " \
          "#{@player[:script]} #{@match.state.inspect} " \
          "#{@player[:time_left]} #{@player[:side]}"
    r, w = IO.pipe
    pid = spawn(cmd, rlimit_cpu: @player[:time_left] / 1000, out: w)
    start_time = Process.times
    Process.wait pid
    w.close
    @move = r.read
    r.close
    end_time = Process.times
    total_time = end_time.cutime - start_time.cutime +
                 end_time.cstime - start_time.cstime
    p ["time_taken", total_time]
    total_time = (total_time * 1000).to_i
    @player[:time_left] -= total_time
  end
  
  # Just save the results to the database
  def save
    @player[:player].stat.save
    @opponent[:player].stat.save
    @match.save
  end

  def make_move
    @match.state = @ttt.makeMove(@match.state, @move, @player[:side])
    move_list = JSON.parse(@match.moveHistory)
    move_list << {"piece" => @player[:side], "move" => @move}
    @match.moveHistory = JSON.generate(move_list)
    @match.toggle :turn
    @match.save
  end

  def publish_move
    game_status = {"piece" => @player[:side], "move" => @move,
                   "state" => @match.state}
    @redis.publish(@redis_channel, JSON.generate(game_status))
  end
  
  def publish_result
    @redis.publish(@redis_channel, JSON.generate({"result" => @match.result}))
  end

  def player_victory
    @match.result = @player[:side]
    @player[:player].stat.wins += 1
    @opponent[:player].stat.losses +=1
    save
    publish_result
  end

  def opponent_victory
    @match.result = @opponent[:side]
    @player[:player].stat.losses += 1
    @opponent[:player].stat.wins +=1
    save
    publish_result
  end

  def tie
    @match.result = "t"
    @player[:player].stat.ties += 1
    @opponent[:player].stat.ties +=1
    save
    publish_result
  end    

  def timeout
    @player[:player].stat.timeouts += 1
    opponent_victory
  end
  
  def illegal
    @player[:player].stat.illegals += 1
    opponent_victory
  end

end
