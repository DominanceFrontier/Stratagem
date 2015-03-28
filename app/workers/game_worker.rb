# app/workers/game_worker.rb

# TODO
#   Report time info back to the client
#   There seems to be a need for an association model between player and match.
#   It would save stuff such as the player's piece, times and moves.
#   Get to it together with Ryan sometime

class GameWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(match_id)

    redis = Redis.new(:url => ENV['REDISTOGO_URL'])
    redis_channel = match_id.to_s
    
    @match = Match.find(match_id)
    build_duelers # Currently sets challengee as second player
    
    cxt = V8::Context.new
    cxt.load("#{Rails.root.to_s}/games/ttt/game.js")
    ttt = cxt[:ttt]

    while @match.result == "open" do
      sleep 3

      # Just following get_move.py documentation here, hence piece => player
      state = @match.state.inspect
      time_left = @player[:time_left]
      player = @player[:piece]

      path = @player[:location]
      script = @player[:script]
      
      puts "\n\n\n"
      p [@player, state, time_left, player, path, script]
      puts "\n\n\n"

      # Maybe factor this out into a private method later, but arguments nonsense only?
      # Just calls the runner and times it, pretty much.
      cmd = "python #{Rails.root.to_s}/runner.py #{path} #{script} #{state} #{time_left} #{player}"
      r, w = IO.pipe
      pid = spawn(cmd, rlimit_cpu: time_left, out: w)
      start_time = Process.times
      Process.wait pid
      w.close
      move = r.read
      r.close

      if move.empty?
        p ["failure!", "timed out!"]
        timeout
        break        
      end
      p ["success!", move]

      end_time = Process.times
      total_time = end_time.cutime - start_time.cutime + end_time.cstime - start_time.cstime
      total_time = (total_time * 1000).to_i
      time_left -= total_time
      @player[:time_left] = time_left
      
      p [cmd, move, total_time, time_left]
      
      valid = ttt.isValidMove(@match.state, move)

      p [move, valid]
      
      unless valid
        opponent_victory
        break
      end

      @match.state = ttt.makeMove(@match.state, move, player)
      @match.moveHistory = JSON.generate(JSON.parse(@match.moveHistory) <<
                                         {"piece" => player, "move" => move})
      p @match.state
      @match.save
      
      game_over = ttt.checkForWinner(@match.state, player)
      p game_over
      if game_over == player
        player_victory
      elsif game_over == "T"
        tie
      end

      tttStatus = {"piece" => player, "move" => move, "state" => @match.state}
      
      redis.publish(redis_channel, JSON.generate(tttStatus))

      @player, @opponent = @opponent, @player
    end

    redis.publish(redis_channel, JSON.generate({"result" => @match.result}))
    
  end

  private

  # Simply sets the initial players for the game
  def build_duelers
    @player = build_player(@match.mario)
    @player[:piece] = 'x'
    @opponent = build_player(@match.luigi)
    @opponent[:piece] = 'o'
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

  def player_victory
    @match.result = @player[:piece]
    @player[:player].stat.wins += 1
    @opponent[:player].stat.losses +=1
    save
  end

  def timeout
    @player[:player].stat.timeouts += 1
    opponent_victory
  end
  
  def opponent_victory
    @match.result = @opponent[:piece]
    @player[:player].stat.losses += 1
    @opponent[:player].stat.wins +=1
    save
  end

  def tie
    @match.result = "t"
    @player[:player].stat.ties += 1
    @opponent[:player].stat.ties +=1
    save
  end    

  # Just save the results to the database
  def save
    @player[:player].stat.save
    @opponent[:player].stat.save
    @match.save
  end

end
