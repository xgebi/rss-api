##
# Standard Post serializer, don't use when displaying lists
#
class PostSerializer < ActiveModel::Serializer
  attributes :id, :read, :post_type
  has_one :article_content
  has_one :feed
end
