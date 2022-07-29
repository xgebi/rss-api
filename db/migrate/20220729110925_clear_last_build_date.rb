class ClearLastBuildDate < ActiveRecord::Migration[7.0]
  def change
    Feed.all.each do |f|
      f.last_build_date = nil
      f.save
    end
  end
end
