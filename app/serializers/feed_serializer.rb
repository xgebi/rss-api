class FeedSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :uri, :description, :feed_type, :last_successful_update
end
