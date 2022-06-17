class CreateFeeds < ActiveRecord::Migration[7.0]
  def change
    create_table :feeds, id: :uuid do |t|
      t.belongs_to :user, index: true, type: :uuid, foreign_key: true
      t.string :title
      t.string :uri
      t.text :description
      t.datetime :added
      t.timestamps
    end
  end
end
