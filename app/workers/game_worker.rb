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
    cxt.load("#{Rails.root.to_s}/app/assets/javascripts/games/ttt/game.js")
    ttt = cxt[:ttt]

    i = 0
    while @match.result == "open" do
      i += 1
      sleep 10      
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
        @match.result = player == mario ? "luigi" : "mario"
        @match.save
        break
      end

      @match.state = ttt.makeMove(@match.state, move, piece)
      @match.moveHistory = JSON.generate(JSON.parse(@match.moveHistory) << [move, piece])

      if ttt.checkForWinner(@match.state, piece)
        @match.result = player == mario ? "mario" : "luigi"
      end

      @match.save

      piece = piece == 'X' ? 'O' : 'X'
      
      redis.publish("global", "{\"handle\":\"move#{i}\",\"text\":\"#{move}\"}")  
    end
  end

end
