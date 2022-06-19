require 'nokogiri'

class ProcessFeedService
  include HTTParty

  def process_articles
    Feed.select(feed_type: 'article').distinct.pluck("uri").map do |uri|
      response = HTTParty.get(uri)

      if response.code == 200
        rss_doc = Nokogiri::XML(response.body)
        rss_doc.css("item").map do |item|
          p item.at_css("title").content
        end
      end
    end
  end

  def process_podcasts
    Feed.select(feed_type: 'podcast').distinct.pluck("uri")
  end
end
