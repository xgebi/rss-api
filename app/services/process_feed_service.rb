class ProcessFeedService
  include HTTParty
  attr_accessor :current_user

  def initialize(user = nil)
    super()
    @current_user = user if user
  end

  def process_articles
    Feed.all.where(user_id: @current_user, feed_type: 'article').distinct.pluck('uri').each do |uri|
      process_creating_articles uri
    end
  end

  def process_podcasts
    Feed.all.where(user_id: @current_user, feed_type: 'episode').distinct.pluck('uri').each do |uri|
      process_creating_podcasts uri
    end
  end

  # This is future-proofing
  def process_all_articles
    Feed.all.where(feed_type: 'article').distinct.pluck('uri').each do |uri|
      process_creating_articles uri
    end
  end

  # This is future-proofing
  def process_all_podcasts
    Feed.all.where(feed_type: 'podcast').distinct.pluck('uri').each do |uri|
      process_creating_articles uri
    end
  end

  private

  def save_posts(article_content, uri)
    # This is not final, with a lot of users there should be a priority insertion
    # and rest to be inserted through queue, depending on database architecture
    # For the time being it's ok
    Feed.all.where(uri:).each do |feed|
      post = Post.new(
        feed:,
        read: false,
        article_content:,
        user: feed.user,
        post_type: feed.feed_type
      )
      post.save!
    end
  end

  def process_creating_articles(uri)
    response = HTTParty.get(uri)

    return unless response.code == 200

    rss_doc = Nokogiri::XML(response.body)
    @namespaces = map_namespace rss_doc
    rss_doc.css('item').map do |item|
      next if ArticleContent.find_by(guid: item.at_css('guid').content)

      ac = create_common_article_rss item
      ac.media_link = item.at_css('enclosure')['url'] if item.at_css('enclosure')

      ac.save!
      save_posts ac, uri
    end
    rss_doc.css('entry').map do |item|
      next if ArticleContent.find_by(guid: item.at_css('id').content)

      ac = create_common_article_atom item

      ac.save!
      save_posts ac, uri
    end
  end

  def process_creating_podcasts(uri)
    response = HTTParty.get(uri)

    return unless response.code == 200

    rss_doc = Nokogiri::XML(response.body)
    @namespaces = map_namespace rss_doc
    rss_doc.css('item').map do |item|
      next if ArticleContent.find_by(guid: item.at_css('guid').content)

      ac = create_common_article_rss item
      ac.itunes_duration = item.at_css('itunes|duration').content if item.at_css('itunes|duration')
      ac.itunes_summary = item.at_css('itunes|summary').content if item.at_css('itunes|summary')
      ac.media_link = item.at_css('enclosure')['url'] if item.at_css('enclosure')
      ac.save!

      ac.save!
      save_posts ac, uri
    end
  end

  private
  def create_common_article_rss(item)
    ac = ArticleContent.new(
      guid: item.at_css('guid').content,
      title: item.at_css('title').content,
      pub_date: DateTime.parse(item.at_css('pubDate').content),
      link: item.at_css('link').content
    )
    ac.description = item.at_css('description').content if item.at_css('description')
    byebug
    ac.content = item.at_css('content|encoded')&.content if @namespaces.index('content') && item.at_css('content|encoded')

    ac
  end

  def create_common_article_atom(item)
    ac = ArticleContent.new(
      guid: item.at_css('id').content,
      title: item.at_css('title').content,
      pub_date: DateTime.parse(item.at_css('published').content),
      link: item.at_css('link').content
    )
    ac.description = item.at_css('description').content if item.at_css('description')
    ac.content = item.at_css('content').content if item.at_css('content')

    ac
  end

  def map_namespace(doc)
    doc.namespaces.keys.map do |key|
      if key.index(':')
        key[key.index(':') + 1, key.length]
      end
    end
  end
end

