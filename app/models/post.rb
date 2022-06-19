class Post < ApplicationRecord
  belongs_to :feed
  belongs_to :article_content
  belongs_to :user
end
