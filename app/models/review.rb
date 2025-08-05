class Review < ApplicationRecord
  belongs_to :onsen

  has_many_attached :images

  validates :images,
    content_type: [ "image/jpeg", "image/png", "image/gif" ], # 許可ファイル形式
    size: { less_than: 3.megabytes },                       # 1枚あたり3MB未満
    limit: { max: 3 }                                        # 最大3枚まで
end
