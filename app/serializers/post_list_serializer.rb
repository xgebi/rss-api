##
# Serializer used when displaying post list
#
class PostListSerializer < ActiveModel::Serializer
  attributes :id, :read, :post_type
  has_one :article_content
  has_one :feed

  ##
  # Nested serializer which picks only important things from feed
  #
  class FeedSerializer < ActiveModel::Serializer
    attributes :title
  end

  ##
  # Nested serializer which picks only important things from article content
  #
  class ArticleContentSerializer < ActiveModel::Serializer
    attributes :title, :itunes_duration, :pub_date, :media_type
  end
end
