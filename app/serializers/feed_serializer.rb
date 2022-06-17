class FeedSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :uri, :description
end
