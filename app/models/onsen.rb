class Onsen < ApplicationRecord
  has_many :reviews, dependent: :destroy

  has_many_attached :images

  validates :images,
    content_type: { in: [ "image/jpeg", "image/png", "image/gif" ], message: "must be a JPEG, PNG, or GIF" },
    size: { less_than: 5.megabytes, message: "must be less than 5MB" },
    limit: { max: 5, message: "cannot exceed 5 images" }
end
