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
  
end
