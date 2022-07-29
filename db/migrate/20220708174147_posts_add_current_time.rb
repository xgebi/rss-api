class PostsAddCurrentTime < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :current_time, :bigint
  end
end
