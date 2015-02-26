class AisController < ApplicationController
  before_action :logged_in_user

  def show
    @ai = Ai.find(params[:id])
    @match = Match.new
    @match.mario = @ai.id@ai.matches.build
  end
  
  def new
    @ai = current_user.ais.build
  end
  
  def create
    @ai = current_user.ais.build(ai_params)
    if @ai.save
      flash[:success] = "AI Script uploaded!"
      redirect_to current_user
    else
      flash[:danger] = "Sorry, upload failed."
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
