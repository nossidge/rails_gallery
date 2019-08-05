# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :gallery

  has_one_attached :file

  validates :file,
            attached:     true,
            content_type: %w[image/png image/jpg image/jpeg],
            size:         {
              less_than: 2.megabytes,
              message:   'too large (must be below 2MB)'
            }

  # Is the parameter User approved to perform edits to this record?
  def authorised?(comparison_user)
    return false unless comparison_user

    comparison_user.id == gallery.user.id
  end
end
