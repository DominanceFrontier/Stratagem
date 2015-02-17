class AisController < ApplicationController
  before_action :logged_in_user

  def new
  end
  
  def create
    @ai = current_user.ais.build(ai_params)
    if @ai.save
      flash[:success] = "AI Script uploaded!"
      redirect_to current_user
    else
      flash[:danger] = "???"
      redirect_to contact_path
    end
  end

  def destroy
  end

  private

  def ai_params
      params.require(:ai).permit(:name, :language, :location)
  end
end
