class ArticleContentsMakeGuidUnique < ActiveRecord::Migration[7.0]
  def change
    add_index(:article_contents, :guid, unique: true)
  end
end
