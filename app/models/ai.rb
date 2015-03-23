class Ai < ActiveRecord::Base
  mount_uploader :location, ScriptUploader

  #----------------------------------------------------------------------------
  # Relationships
  #----------------------------------------------------------------------------
  belongs_to :user
  has_many :matches, as: :mario, dependent: :destroy
  has_many :matches, as: :luigi, dependent: :destroy
  has_one :stat, as: :player, dependent: :destroy
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Callbacks
  #----------------------------------------------------------------------------
  before_create :build_default_stat
  #----------------------------------------------------------------------------

  #----------------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------------
  validates :user_id, presence: true
  validates :name, presence: true, length: { minimum: 5, maximum: 36 }
  validates :location, presence: true
  validate :script_size
  #----------------------------------------------------------------------------
  
  private

  def build_default_stat
    build_stat
    true
  end

  def script_size
    if location.size > 1.megabytes
      errors.add(:location, " is too large!")
    end
  end
  
end
