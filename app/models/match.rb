class Match < ActiveRecord::Base
  after_create :notify
  
  validates :mario, presence: true
  validates :luigi, presence: true

  private

  def notify
    EM.run {
    client = Faye::Client.new('/faye')
    client.publish('/foo', 'text' => 'Hello world')
    }
    # while True do
    #   RubyPython.start  
    #   sys = RubyPython.import("sys")
    #   sys.path.append()
    
    #   test = RubyPython.import("get_move")
    #   @text = test.get_move(params[:move][:match_state], params[:move][:time_left]).rubify 
    
    #   RubyPython.stop
    # end
  end

end
