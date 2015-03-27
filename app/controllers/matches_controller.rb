class MatchesController < ApplicationController
  before_action :logged_in_user, only: [:show]

  def index
    @matches = Match.paginate(page: params[:page])
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
    
    @match = Match.new(mario: mario, luigi: luigi, time_alloted: paras[:time_alloted])

    if @match.save
      redirect_to @match
    else
      flash[:danger] = "Sorry something went wrong."
      redirect_to contact_path
    end
    
  end

  def show
    @match = Match.find(params[:id])    
    @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
    GameWorker.perform_async @match.id if @match.result == "open"
  end

  private

  def match_params
    params.require(:match).permit(:type, :mario, :luigi, :time_alloted)
  end

  private
  
end
