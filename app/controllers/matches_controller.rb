class MatchesController < ApplicationController
  before_action :logged_in_user, only: [:show]
  
  def create
    paras = match_params
    paras[:luigi] = Rails.root.to_s + '/public' + paras[:luigi]
    @match = Match.new(paras)
    if @match.save
      redirect_to @match
    else
      flash[:danger] = "Sorry something went wrong."
      redirect_to root_path
    end
  end

  def show
    @match = Match.find(params[:id])

    puts "\n\n\n"
    p @match.state
    puts "\n\n\n"
    
    @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
    playttt(@match.id)
    GameWorker.perform_async @match.id
  end

  private

  def match_params
    params.require(:match).permit(:mario, :luigi)
  end

  private

  def correct_user
    @user = Match.find(params[:id])
  end

  def playttt(match_id)
    @match = Match.find(match_id)
    
    mario = @match.mario.split('/')
    mario_path = mario[0...-1].join('/')
    mario = mario[-1][0...-3]

    luigi = @match.luigi.split('/')
    luigi_path = luigi[0...-1].join('/')
    luigi = luigi[-1][0...-3]

    move = ""

    piece = 'X'
    
    cxt = V8::Context.new
    cxt.load("#{Rails.root.to_s}/app/assets/javascripts/games/ttt/game.js")
    ttt = cxt[:ttt]

    while @match.result == "open" do
      
      if piece == 'X'
        path = mario_path
        player = mario
      else
        path = luigi_path
        player = luigi
      end

      puts "\n\n\n"
      p [path, player]
      p @match.state
      puts "\n\n\n"
      
      # RubyPython.start  
      # sys = RubyPython.import("sys")
      # sys.path.append(path)
      # p = RubyPython.import(player)
      # sys.path.pop()
      # move = p.get_move(@match.state)
      # RubyPython.stop

      move = "[1,2]"
      
      valid = ttt.isValidMove(@match.state, move)
      p move
      p valid
      unless valid
        @match.result = player == mario ? "luigi" : "mario"
        @match.save
        break
      end

      @match.state = ttt.makeMove(@match.state, move, piece)
      @match.moveHistory = JSON.generate(JSON.parse(@match.moveHistory) << [move, piece])

      if ttt.checkForWinner(@match.state)
        @match.result = player == mario ? "mario" : "luigi"
      end

      @match.save

      piece = piece == 'X' ? 'O' : 'X'
      
    end

  end
  
end
