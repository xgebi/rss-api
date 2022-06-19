class ProcessFeedService
  include HTTParty

  def process_articles
    Feed.all.where(user_id: current_user.id, feed_type: 'article').distinct.pluck('uri').each do |uri|
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

        save_posts ac
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
        save_posts ac
      end
    end
  end

  private
  def save_posts(article_content)
    # This is not final, with a lot of users there should be a priority insertion
    # and rest to be inserted through queue, depending on database architecture
    # For the time being it's ok
    Feed.all.where(uri:).each do |feed|
      post = Post.new(
        feed:,
        read: false,
        article_content:
      )
      post.save!
    end
  end
end

