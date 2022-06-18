class AdjustFeedsColumnsTwo < ActiveRecord::Migration[7.0]
  def change
    change_table :feeds do |t|
      t.rename :updatePeriod, :update_period
      t.rename :updateFrequency, :update_frequency
    end
  end
end
