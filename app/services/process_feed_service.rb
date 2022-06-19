require 'nokogiri'

class ProcessFeedService
  include HTTParty

  def process_articles
    Feed.all.where(user_id: current_user.id, feed_type: 'article').map do |uri|
      response = HTTParty.get(uri)

      next unless response.code == 200

      rss_doc = Nokogiri::XML(response.body)
      rss_doc.css('item').map do |item|
        next if ArticleContent.find_by(guid: item.at_css('guid').content)

        ac = ArticleContent.new(
          guid: item.at_css('guid').content,
          title: item.at_css('title').content,
          description: item.at_css('description').content,
          content: item.at_css('content|encoded').content,
          pub_date: item.at_css('pubDate').content,
          link: item.at_css('link').content
        )
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

        ac = ArticleContent.new(
          guid: item.at_css('guid').content,
          title: item.at_css('title').content,
          description: item.at_css('description').content,
          media_link: item.at_css('enclosure').content,
          itunes_duration: item.at_css('itunes|duration').content,
          itunes_summary: item.at_css('itunes|summary').content,
          content: item.at_css('content|encoded').content,
          pub_date: item.at_css('pubDate').content,
          link: item.at_css('link').content
        )
        ac.save!
      end
    end
  end
end

