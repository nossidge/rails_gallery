class Image < ApplicationRecord
  belongs_to :gallery

  has_one_attached :file

  validates(
    :file,
    attached: true,
    content_type: ['image/png', 'image/jpg', 'image/jpeg'],
    size: {
      less_than: 2.megabytes,
      message: 'too large (must be below 2MB)'
    }
  )
end
