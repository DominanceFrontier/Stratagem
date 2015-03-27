class Stat < ActiveRecord::Base
    
  #----------------------------------------------------------------------------
  # Relationships
  #----------------------------------------------------------------------------
  belongs_to :player, polymorphic: true
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------------
  validates :player, presence: true
  #----------------------------------------------------------------------------
  
  def win_percentage
    begin
      return (self.wins / self.player.matches.count * 100).round(2)
    rescue ZeroDivisionError
      return 100
    end
  end

end
