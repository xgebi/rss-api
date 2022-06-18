class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :article_contents, id: :uuid do |t|
      t.string :title
      t.string :uri
      t.text :content
    end

    create_table :posts, id: :uuid do |t|
      t.belongs_to :feed, type: :uuid, index: true, foreign_key: true
      t.belongs_to :article_content, type: :uuid, index: true, foreign_key: true
      t.datetime :added
      t.datetime :updated
      t.boolean :read

      t.timestamps
    end
  end
end
