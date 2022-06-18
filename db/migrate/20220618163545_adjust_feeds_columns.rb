class AdjustFeedsColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :updatePeriod, :string
    add_column :feeds, :updateFrequency, :integer
  end
end
