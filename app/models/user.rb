class User < ActiveRecord::Base
  has_many :ais, dependent: :destroy
  before_save { self.email.downcase! }
  validates :username, presence: true, length: { minimum: 5, maximum: 36 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { minimum: 8, maximum: 255 },
  format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6, maximum: 30 }
end
