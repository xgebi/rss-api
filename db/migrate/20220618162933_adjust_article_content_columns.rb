class AdjustArticleContentColumns < ActiveRecord::Migration[7.0]
  def change
    change_table :article_contents do |t|
      t.rename :uri, :guid
    end
    add_column :article_contents, :description, :string
    add_column :article_contents, :pub_date, :string
    add_column :article_contents, :media_link, :string
    add_column :article_contents, :itunes_duration, :integer
    add_column :article_contents, :itunes_summary, :string
    add_column :article_contents, :link, :string
  end
end
