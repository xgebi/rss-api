class AddLastSuccessToFeed < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :last_successful_update, :datetime
  end
end
