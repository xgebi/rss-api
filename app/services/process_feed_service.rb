require 'nokogiri'

class ProcessFeedService
  include HTTParty

  def process_articles
    Feed.select(feed_type: 'article').distinct.pluck("uri").map do |uri|
      doc = Nokogiri::HTML(self.class.get(uri))
      doc.css("item").each do |item|
        byebug
      end
    end
  end

  def process_podcasts
    Feed.select(feed_type: 'podcast').distinct.pluck("uri")
  end
end
