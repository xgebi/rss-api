class FeedAddLastBuildDate < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :last_build_date, :datetime
    add_column :feeds, :last_checked_date, :datetime
  end
end
