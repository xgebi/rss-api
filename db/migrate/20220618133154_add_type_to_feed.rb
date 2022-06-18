class AddTypeToFeed < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :type, :string, default: 'article'
  end
end
