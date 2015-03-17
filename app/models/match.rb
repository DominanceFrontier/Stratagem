class Match < ActiveRecord::Base
  
  #----------------------------------------------------------------------------
  # Relationships
  #----------------------------------------------------------------------------
  belongs_to :mario, polymorphic: true
  belongs_to :luigi, polymorphic: true
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------------
  validates :mario, presence: true
  validates :luigi, presence: true
  #----------------------------------------------------------------------------
  
end
