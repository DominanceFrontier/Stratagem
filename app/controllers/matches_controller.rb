class MatchesController < ApplicationController
  
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
  end

  private

  def match_params
    params.require(:match).permit(:mario, :luigi)
  end  
  
end
