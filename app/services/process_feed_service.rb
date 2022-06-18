require 'nokogiri'

class ProcessFeedService
  include HTTParty

  def process_articles
    Feed.select(feed_type: 'article').distinct.pluck("uri").map do |uri|

    end
  end

  def process_podcasts
    Feed.select(feed_type: 'podcast').distinct.pluck("uri")
  end

  private
  def process_common

  end
end
