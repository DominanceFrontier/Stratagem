class Ai < ActiveRecord::Base
  mount_uploader :location, ScriptUploader

  #----------------------------------------------------------------------------
  # Relationships
  #----------------------------------------------------------------------------
  belongs_to :user
  belongs_to :game
  has_many :mario_matches, as: :mario, class_name: "Match", dependent: :destroy
  has_many :luigi_matches, as: :luigi, class_name: "Match", dependent: :destroy
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
  validates :username, presence: true, length: { minimum: 5, maximum: 36 }
  validates :location, presence: true
  validate :script_size
  #----------------------------------------------------------------------------

  def matches
    Match.where(["mario_type = :type and mario_id = :id " \
                 "or luigi_type = :type and luigi_id = :id",
                 { type: "Ai", id: self.id }])
  end

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
