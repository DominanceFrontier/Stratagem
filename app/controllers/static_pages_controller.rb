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
    @p1_path = @p1.location.current_path
    @p2_path = @p2.location.current_path
    @state = "         "

    client = Faye::Client.new('/faye')

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
