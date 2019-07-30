class User < ApplicationRecord
  has_many :galleries

  before_save { self.email = email.downcase }

  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }, format: { with: /@/ }
  validates :password, presence: true, length: { minimum: 6 }

  validates_confirmation_of :password
  has_secure_password
end
