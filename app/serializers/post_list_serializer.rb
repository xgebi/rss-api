class PostListSerializer < ActiveModel::Serializer
  attributes :id, :read, :post_type
  has_one :article_content
  has_one :feed

  class FeedSerializer < ActiveModel::Serializer
    attributes :title
  end

  class ArticleContentSerializer < ActiveModel::Serializer
    attributes :title, :itunes_duration, :pub_date
  end
end
