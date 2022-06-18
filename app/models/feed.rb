class Feed < ApplicationRecord
  belongs_to :user
  has_many :posts, dependent: :destroy

  validates :uri, url: { no_local: true }
end
