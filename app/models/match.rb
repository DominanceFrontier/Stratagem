class Match < ActiveRecord::Base 

  validates :mario, presence: true
  validates :luigi, presence: true

end
