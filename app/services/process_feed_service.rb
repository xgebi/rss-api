require 'nokogiri'

class ProcessFeedService
  include HTTParty

  def process_articles
    Feed.select(feed_type: 'article').distinct.pluck('uri').map do |uri|
      response = HTTParty.get(uri)

      next unless response.code == 200

      rss_doc = Nokogiri::XML(response.body)
      rss_doc.css('item').map do |item|
        next if ArticleContent.find_by(guid: item.at_css('guid').content)

        ac = ArticleContent.new
        ac.guid = item.at_css('guid').content
        ac.title = item.at_css('title').content
        ac.description = item.at_css('description').content
        ac.content = item.at_css('content|encoded').content
        ac.pub_date = item.at_css('pubDate').content
        ac.link = item.at_css('link').content
        ac.save!
      end
    end
  end

  def process_podcasts
    Feed.select(feed_type: 'podcast').distinct.pluck('uri').map do |uri|
      response = HTTParty.get(uri)

      next unless response.code == 200

      rss_doc = Nokogiri::XML(response.body)
      rss_doc.css('item').map do |item|
        next if ArticleContent.find_by(guid: item.at_css('guid').content)

        ac = ArticleContent.new
        ac.guid = item.at_css('guid').content
        ac.title = item.at_css('title').content
        ac.media_link = item.at_css('enclosure').content
        ac.itunes_duration = item.at_css('itunes|duration').content
        ac.itunes_summary = item.at_css('itunes|summary').content
        ac.description = item.at_css('description').content
        ac.content = item.at_css('content|encoded').content
        ac.pub_date = item.at_css('pubDate').content
        ac.link = item.at_css('link').content
        ac.save!
      end
    end
  end
end

