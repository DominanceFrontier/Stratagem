# app/workers/game_worker.rb
class GameWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(match_id)

    redis = Redis.new(:url => ENV['REDISTOGO_URL'])
    
    @match = Match.find(match_id)
    
    mario = @match.mario.split('/')
    mario_path = mario[0...-1].join('/')
    mario = mario[-1][0...-3]

    luigi = @match.luigi.split('/')
    luigi_path = luigi[0...-1].join('/')
    luigi = luigi[-1][0...-3]

    piece = 'X'
    
    cxt = V8::Context.new
    cxt.load("#{Rails.root.to_s}/games/ttt/game.js")
    ttt = cxt[:ttt]

    while @match.result == "open" do
      sleep 3      
      if piece == 'X'
        path = mario_path
        player = mario
      else
        path = luigi_path
        player = luigi
      end

      puts "\n\n\n"
      p [path, player]
      p [@match.state, piece]
      puts "\n\n\n"
      
      cmd = "python #{Rails.root.to_s}/runner.py #{path} #{player} #{@match.state.inspect}"
      move, status = Open3.capture2(cmd)
      #move = move.to_s
      p [cmd, move, status]
      valid = ttt.isValidMove(@match.state, move)

      p [move, valid, status]
      
      unless valid
        @match.result = piece
        @match.save
        break
      end

      @match.state = ttt.makeMove(@match.state, move, piece)
      @match.moveHistory = JSON.generate(JSON.parse(@match.moveHistory) \
                                         << {"piece" => piece, "move" => move})

      gameOver = ttt.checkForWinner(@match.state, piece)
      if gameOver == piece
        @match.result = piece
      elsif gameOver == "T"
        @match.result = "tie"
      end

      @match.save

      tttStatus = {"piece" => piece, "move" => move, "state" => @match.state}
      
      redis.publish("global", JSON.generate(tttStatus))

      piece = piece == 'X' ? 'O' : 'X'
    end

    redis.publish("global", JSON.generate({"result" => @match.result}))
    
  end

end