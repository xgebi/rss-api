class ArticlesContentsChangePubDataDataType < ActiveRecord::Migration[7.0]
  def change
    rename_column :article_contents, :pub_date, :pub_date_string
    add_column :article_contents, :pub_date, :datetime

    ArticleContent.reset_column_information
    ArticleContent.all.each do|ac|
      ac.pub_date = DateTime.parse(ac.pub_date_string)
      ac.save
    end
    remove_column :article_contents, :pub_date_string
  end
end
