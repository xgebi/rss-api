class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.belongs_to :feed, type: :uuid, index: true, foreign_key: true
      t.datetime :added
      t.datetime :updated
      t.boolean :read

      t.timestamps
    end

    create_table :article_content, id: :uuid do |t|
      t.belongs_to :post, type: :uuid, index: true, foreign_key: true
      t.string :title
      t.string :uri
      t.text :content
    end
  end
end
