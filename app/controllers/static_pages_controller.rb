class StaticPagesController < ApplicationController

  def home
    @ai = current_user.ais.build if logged_in?
  end

  def about
  end

  def help
  end

  def contact
  end

  def match
    @p1 = Ai.find(params[:p1_id])
    @p2 = Ai.find(params[:champion])
  end
  
end
