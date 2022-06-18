class RenameTypeColumnInFeeds < ActiveRecord::Migration[7.0]
  def change
    change_table :feeds do |t|
      t.rename :type, :feed_type
    end

  end
end
