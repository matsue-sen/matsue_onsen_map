class Onsen < ApplicationRecord
  has_many :reviews, dependent: :destroy
end
