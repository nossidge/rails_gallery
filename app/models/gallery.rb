class Gallery < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :description, length: { maximum: 255 }
end
