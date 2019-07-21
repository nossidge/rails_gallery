class User < ApplicationRecord
  before_save { self.email = email.downcase }

  validates_confirmation_of :password
  has_secure_password

  validates :username, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }, format: { with: /@/ }
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }
end
