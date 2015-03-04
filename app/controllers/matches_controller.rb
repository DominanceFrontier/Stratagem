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
    @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
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
  
end
