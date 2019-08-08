# frozen_string_literal: true

class User < ApplicationRecord
  has_many :galleries, dependent: :destroy

  before_save { self.email = email.downcase }

  validates :username,
            presence:   true,
            uniqueness: true,
            length:     { maximum: 25 }

  validates :email,
            presence:   true,
            uniqueness: true,
            length:     { maximum: 255 },
            format:     { with: /@/ }

  validates :password,
            presence:     true,
            confirmation: true,
            length:       { minimum: 6 }

  has_secure_password

  # Is the parameter User approved to perform edits to this record?
  def authorised?(comparison_user)
    return false unless comparison_user

    comparison_user.id == id
  end

  # Run a value against all validators for a specific field.
  # Output can be retrieved from the '#errors' collection, as usual.
  # https://stackoverflow.com/a/27047136
  def validate_field(field, value)
    self.class.validators_on(field).each do |validator|
      validator.validate_each(self, field, value)
    end
  end
end
