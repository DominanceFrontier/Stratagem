class Ai < ActiveRecord::Base
  belongs_to :user
  mount_uploader :location, ScriptUploader
  
  validates :user_id, presence: true
  validates :name, presence: true, length: { minimum: 5, maximum: 36 }
  validates :location, presence: true
  validate :script_size

  private

  def script_size
    if location.size > 1.megabytes
      errors.add(:location, " is too large!")
    end
  end
  
end
