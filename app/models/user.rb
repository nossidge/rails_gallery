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

  ##
  # Is the parameter User approved to perform edits to this record?
  #
  # @param comparison_user [User]
  #   User that is requesting write access to this record.
  #   This is most likely to be the `current_user`
  #
  def authorised?(comparison_user)
    return false unless comparison_user

    comparison_user.id == id
  end

  ##
  # Run a value against all validators for a specific field.
  # https://stackoverflow.com/a/27047136
  #
  # @param [String, Symbol] field
  #   The name of the field
  # @param [void] value
  #   The value to save to the field
  # @return [void]
  #   Output should be retrieved from the {#errors} collection
  #
  def validate_field(field, value)
    self.class.validators_on(field).each do |validator|
      validator.validate_each(self, field, value)
    end
  end

  ##
  # Run a value against all validators for all fields.
  # This is destructive to the input parameter hash; a 'password_confirmation'
  # key will be deleted if present.
  #
  # @param [ActionController::Parameters] params
  #   Make sure that `permitted: true`
  #
  def validate_params!(params)
    validate_field(:username, params['username']) if params['username']
    validate_field(:email, params['email']) if params['email']

    return unless params['password']

    validate_field(:password, params['password'])

    # Manually add this simple comparison check.
    return unless
      params['password'] != params.delete('password_confirmation')

    errors.messages[:password_confirmation] << "doesn't match Password"
  end
end
