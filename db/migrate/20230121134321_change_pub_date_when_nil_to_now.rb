class ChangePubDateWhenNilToNow < ActiveRecord::Migration[7.0]
  def change
    ArticleContent.where(pub_date: nil).each do |ac|
      ac.pub_date = DateTime.now
      ac.save
    end
  end
end
