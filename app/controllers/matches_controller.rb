class MatchesController < ApplicationController
  before_action :logged_in_user, only: [:show]

  def index
    @live_matches = Match.live.paginate(page: params[:page]).order('id DESC')
    @done_matches = Match.done.paginate(page: params[:page]).order('id DESC')
  end

  def create
    paras = match_params
    
    if paras[:type] == "Ai"
      mario = Ai.find(paras[:mario])
      luigi = Ai.find(paras[:luigi])
    elsif paras[:type] == "Human"
      mario = User.find(paras[:mario])
      luigi = User.find(paras[:luigi])
    elsif paras[:type] == "Mixed"
      mario = Ai.find(paras[:mario])
      luigi = User.find(paras[:luigi])
    end

    time_alloted = paras[:time_alloted]
    @match = Match.new(mario: mario, luigi: luigi, time_alloted: time_alloted)

    if @match.save
      GameWorker.perform_async @match.id
      redirect_to @match
    else
      flash[:danger] = "Sorry something went wrong."
      redirect_to contact_path
    end
    
  end

  def show
    @match = Match.find(params[:id])    
    @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
  end

  private

  def match_params
    params.require(:match).permit(:type, :mario, :luigi, :time_alloted)
  end
  
end
