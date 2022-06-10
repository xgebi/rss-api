class CreateUserPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :user_posts, id: :uuid do |t|
      t.belongs_to :users
      t.belongs_to :posts
      t.boolean :read
      t.timestamps
    end
  end
end
