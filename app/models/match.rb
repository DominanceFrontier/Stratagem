class Match < ActiveRecord::Base
  belongs_to :mario, polymorphic: true
  belongs_to :luigi, polymorphic: true
end
