class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :uri, :content, :read
end
