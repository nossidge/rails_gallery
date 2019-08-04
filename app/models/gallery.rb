# frozen_string_literal: true

class Gallery < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy

  validates :name,
            presence: true,
            length:   { minimum: 3, maximum: 50 }

  validates :description,
            length: { maximum: 255 }
end
