class ArticleContentsMediaTypeColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :article_contents, :media_type, :string

    ArticleContent.reset_column_information
    ArticleContent.all.each do|ac|
      ac.media_type = 'audio'
      ac.save
    end
  end
end
