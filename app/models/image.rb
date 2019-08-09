# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :gallery

  acts_as_list scope: :gallery
  default_scope { order(position: :asc) }

  has_one_attached :file

  validates :file,
            attached:     true,
            content_type: %w[image/png image/jpg image/jpeg],
            size:         {
              less_than: 2.megabytes,
              message:   'too large (must be below 2MB)'
            }

  ##
  # Is the parameter User approved to perform edits to this record?
  #
  # @param comparison_user [User]
  #   User that is requesting write access to this record.
  #   This is most likely to be the `current_user`
  #
  def authorised?(comparison_user)
    return false unless comparison_user

    comparison_user.id == gallery.user.id
  end
end
