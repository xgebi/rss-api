class RenameTypeColumnPosts < ActiveRecord::Migration[7.0]
  def change
    change_table :posts do |t|
      t.rename :type, :post_type
    end
  end
end
