class MatchesController < ApplicationController
  #before_action :logged_in_user, only: [:show]

  def index
    @live_matches = Match.live.paginate(page: params[:page]).order('id DESC')
    @done_matches = Match.done.paginate(page: params[:page]).order('id DESC')
  end

  def new
    type = params[:type]
    if type == "Ai"
      @marios = Ai.where(game: params[:game])
      @luigis = Ai.where(game: params[:game])
    elsif type == "Human"
      @marios = User.all
      @luigis = User.all
    elsif type == "H_Ai"
      @marios = User.all
      @luigis = Ai.where(game: params[:game])
    else
      @marios = Ai.where(game: params[:game])
      @luigis = User.all
    end
    @game = Game.find(params[:game])  
    @match = Match.new
  end
  
  def create
    paras = match_params
    game = Game.find(paras[:game])
    
    if paras[:type] == "Ai"
      mario = Ai.find(paras[:mario])
      luigi = Ai.find(paras[:luigi])
    elsif paras[:type] == "Human"
      mario = User.find(paras[:mario])
      luigi = User.find(paras[:luigi])
    elsif paras[:type] == "H_A"
      mario = User.find(paras[:mario])
      luigi = Ai.find(paras[:luigi])
    else
      mario = Ai.find(paras[:mario])
      luigi = User.find(paras[:luigi])
    end

    @match = Match.new(game: game, mario: mario, luigi: luigi,
                       time_alloted: paras[:time_alloted],
                       state: game.initial_state)

    if @match.save
      GameWorker.perform_async @match.id
      redirect_to @match
    else
      flash[:danger] = "Sorry something went wrong."
      redirect_to contact_path
    end    
  end

  def new_match
  end

  def show
    @match = Match.find(params[:id])    
    @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
  end

  private

  def match_params
    params.require(:match).permit(:type, :game, :mario, :luigi, :time_alloted)
  end
  
end
