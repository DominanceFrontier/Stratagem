# TODO: Fix match associations. 
# Issue: The second has_many matches
#        overwrites the first. 
# Must find a way to merge the two

class Match < ActiveRecord::Base
  
  #----------------------------------------------------------------------------
  # Relationships
  #----------------------------------------------------------------------------
  belongs_to :mario, polymorphic: true
  belongs_to :luigi, polymorphic: true
  belongs_to :game
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------------
  validates :mario, presence: true
  validates :luigi, presence: true
  validates :time_alloted, presence: true
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Scopes
  #----------------------------------------------------------------------------
  scope :live, -> { where(result: "open") }
  scope :done, -> { where.not(result: "open") }
end
