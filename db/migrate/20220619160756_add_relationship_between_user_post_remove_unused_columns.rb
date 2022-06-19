class AddRelationshipBetweenUserPostRemoveUnusedColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :user_id, :uuid
    add_foreign_key :posts, :users
    remove_columns :posts, :added, :updated
  end
end
