# app/workers/game_worker.rb

# TODO
#   Report time info back to the client
#   There seems to be a need for an association model between player and match.
#   It would save stuff such as the player's piece, times and moves.
#   Get to it together with Ryan sometime

require "#{Rails.root}/games/checkers/checkersgame"
require "#{Rails.root}/games/ttt/game"

class GameWorker
  include Sidekiq::Worker
  
  def perform(match_id)
    @match = Match.find(match_id)

    # load_js_context # This is actually a *deprecated* method call

    if @match.game.name == "Checkers"
      @game = CheckersGame.new
    else
      # ADD TIC-TAC-TOE object instantiation
      # here
      @game = TicTacToeGame.new 
    end
    
    build_communication_channel    
    build_duelers # Currently sets challenger as second player

    restore_match_state # if resuming a match for whatever reason
    sleep(1)
    
    while @match.result == "open" do
      p ["Turn: ", @player[:symbol]]
      p ["Time left: ", @player[:time_left]]
      fetch_move
      p ["Time left now: ", @player[:time_left]]
      p ["Move: ", @move]

      return timeout if @move.empty? || @player[:time_left] <= 0

      return illegal if @move.nil?
      
      # x = @game.isValidMove(@match.state, @move)
      x = @game.is_valid_move?(@match.state, @move, @player[:symbol])
      p ["Move validation returned: " + x.to_s]
      
      return illegal unless x

      make_move

      publish_move
      
      # game_over = @game.checkForWinner(@match.state, @player[:symbol])      
      game_over = @game.check_for_winner(@match.state, @player[:symbol])

      if game_over == @player[:symbol]
        return player_victory 
      elsif game_over == "t"
        return tie
      end
      
      @player, @opponent = @opponent, @player
    end
  end

  private

  # Load a JavaScript context
  def load_js_context
    @cxt = V8::Context.new
    @cxt.load(@match.game.path)
    @game = @cxt[:game]
  end

  # Connect to redis on the appropriate channel
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
    @player[:symbol] = @match.game.p1_symbol
    @opponent = build_player(@match.luigi)
    @opponent[:symbol] = @match.game.p2_symbol
  end

  # Restore existing state if match is being resumed and not fresh
  def restore_match_state
    move_history = JSON.parse(@match.moveHistory)
    return if move_history.empty?
    num_moves_made = move_history.length
    last_move = move_history[-1]
    last_player = last_move["piece"]
    if last_player = @opponent[:symbol]
      @opponent[:time_left] = last_move["time_left"]
      @player[:time_left] = move_history[-2]["time_left"] unless num_moves_made < 2
    else
      @player[:time_left] = last_move["time_left"]
      @opponent[:time_left] = move_history[-2]["time_left"] unless num_moves_made < 2
      @player, @opponent = @opponent, @player
    end
  end
  
  # Get the move from the relevant script and time it
  def fetch_move
    cmd = "python #{Rails.root.to_s}/runner.py #{@player[:location]} " \
          "#{@player[:script]} #{@match.state.inspect} " \
          "#{@player[:time_left]} #{@player[:symbol]}"
    r, w = IO.pipe
    pid = spawn(cmd, rlimit_cpu: @player[:time_left] / 1000.0, out: w)
    start_time = Process.times
    Process.wait pid
    w.close
    move = r.read
    r.close
    p ["move from runner", move]
    @move = move.empty? ? move : move.split("\n")[-1]
    end_time = Process.times
    total_time = end_time.cutime - start_time.cutime +
                 end_time.cstime - start_time.cstime
    p ["time_taken", total_time]
    total_time = (total_time * 1000).to_i
    @player[:time_left] -= total_time
  end
  
  # Just save the results to the database
  def save_match
    @match.save
  end

  def save_players_stats
    @player[:player].stat.save
    @opponent[:player].stat.save
  end
  
  def save
    save_players_stats
    save_match
  end

  def update_move_history
    move_list = JSON.parse(@match.moveHistory)
    move_list << {"piece" => @player[:symbol], "state" => @match.state,
                  "time_left" => @player[:time_left], "move" => @move}
    @match.moveHistory = JSON.generate(move_list)   
  end

  def make_move
    @match.state = @game.make_move(@match.state, @move, @player[:symbol])
    # @match.state = @game.makeMove(@match.state, @move, @player[:symbol])
    update_move_history
    save_match
  end

  def publish_move
    game_status = {"piece" => @player[:symbol], "state" => @match.state,
                  "time_left" => @player[:time_left], "move" => @move}
    @redis.publish(@redis_channel, JSON.generate(game_status))
  end
  
  def publish_result
    @redis.publish(@redis_channel, JSON.generate({"result" => @match.result}))
  end

  def player_victory
    @match.result = @player[:symbol]
    @player[:player].stat.wins += 1
    @opponent[:player].stat.losses +=1
    save
    publish_result
  end

  def opponent_victory
    @match.result = @opponent[:symbol]
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
    @move = ["Timed Out"]
    @player[:player].stat.timeouts += 1
    update_move_history
    publish_move
    opponent_victory
  end
  
  def illegal
    @move = ["Illegal Move"]
    @player[:player].stat.illegals += 1
    update_move_history
    publish_move
    opponent_victory
  end

end
