
module Game 

  class InterfaceNotImplementedEror < NoMethodError
  end 

  def self.included(cls)
    cls.send(:include, Game::Methods)
    cls.send(:extnd, Game::Methods)
  end 

  module Methods
    def api_not_implemented(cls)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise Game::InterfaceNotImplementedEror.new(
          "#{cls.class.name} needs to implement '#{method_name}'
          for interface #{self.name}!"
        )
    end 
  end 

end  
