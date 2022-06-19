class PostChangeDurationType < ActiveRecord::Migration[7.0]
  def change
    change_column :article_contents, :itunes_duration, :string
  end
end
