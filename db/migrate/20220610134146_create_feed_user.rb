class CreateFeedUser < ActiveRecord::Migration[7.0]
  def change
    create_table :feed_users, id: :uuid do |t|
      t.belongs_to :users
      t.belongs_to :feeds
      t.timestamps
    end
  end
end
