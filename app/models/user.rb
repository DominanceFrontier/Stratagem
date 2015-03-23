class User < ActiveRecord::Base

  #----------------------------------------------------------------------------
  # Accessors
  #----------------------------------------------------------------------------
  attr_accessor :reset_token
  #----------------------------------------------------------------------------
  
  #----------------------------------------------------------------------------
  # Relationships
  #----------------------------------------------------------------------------
  has_many :ais, dependent: :destroy
  has_many :matches, as: :mario, dependent: :destroy
  has_many :matches, as: :luigi, dependent: :destroy
  has_one :stat, as: :player, dependent: :destroy
  #----------------------------------------------------------------------------
  
  #----------------------------------------------------------------------------
  # Callbacks
  #----------------------------------------------------------------------------
  before_create :build_default_stat
  before_save { self.email.downcase! }
  #----------------------------------------------------------------------------
  
  #----------------------------------------------------------------------------
  # Validations
  #----------------------------------------------------------------------------
  validates :username, presence: true, length: { minimum: 5, maximum: 36 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { minimum: 8, maximum: 255 },
  format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6, maximum: 30 }
  #----------------------------------------------------------------------------
  
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
   # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def build_default_stat
    build_stat
    true
  end
  
end
