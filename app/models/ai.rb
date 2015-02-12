class Ai < ActiveRecord::Base
  belongs_to :user
  mount_uploader :location, ScriptUploader
  
  validates :user_id, presence: true
  validates :name, presence: true, length: { minimum: 5, maximum: 36 }
  validates :location, presence: true
end
