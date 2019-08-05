# frozen_string_literal: true

class Gallery < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy

  validates :name,
            presence: true,
            length:   { minimum: 3, maximum: 50 }

  validates :description,
            length: { maximum: 255 }

  # Is the parameter User approved to perform edits to this record?
  def authorised?(comparison_user)
    return false unless comparison_user

    comparison_user.id == user.id
  end
end
