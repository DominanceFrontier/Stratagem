class MatchesController < ApplicationController

  def create
    @p1 = Ai.find(params[:p1_id])
    @p2 = Ai.find(params[:champion])
    @p1_path = @p1.location.current_path
    @p2_path = @p2.location.current_path
    @state = "         "
  end

  def show
    @match = Match.find(params[:id])
  end

  private

  def notify
    #client = Faye::Client.new('/faye')

    while True do
      RubyPython.start  
      sys = RubyPython.import("sys")
      sys.path.append()
      
      test = RubyPython.import("get_move")
      @text = test.get_move(params[:move][:match_state], params[:move][:time_left]).rubify 
      
      RubyPython.stop
    end
  end
  
  
end
