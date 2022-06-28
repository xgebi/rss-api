##
# Service to encapsulate processing RSS and Atom feeds for articles and podcasts
#
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
      if item.at_css('enclosure')
        ac.media_link = item.at_css('enclosure')['url']
        media_type = item.at_css('enclosure')['type']
        media_type = media_type[0, media_type.index('/')] if media_type.index('/')
        ac.media_type = media_type
      end

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
      if @namespaces.index('itunes')
        ac.itunes_duration = item.at_css('itunes|duration').content if item.at_css('itunes|duration')
        ac = transform_duration(ac) if item.at_css('itunes|duration')
        ac.itunes_summary = item.at_css('itunes|summary').content if item.at_css('itunes|summary')
      end
      if item.at_css('enclosure')
        ac.media_link = item.at_css('enclosure')['url']
        ac.media_type = item.at_css('enclosure')['url'][0, item.at_css('enclosure')['url'].index('/')]
      end
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
    )
    ac.link = item.at_css('link').content if item.at_css('link')
    ac.description = item.at_css('description').content if item.at_css('description')
    if @namespaces.index('content') && item.at_css('content|encoded')
      ac.content = item.at_css('content|encoded')&.content
    end

    ac
  end

  def create_common_article_atom(item)
    ac = ArticleContent.new(
      guid: item.at_css('id').content,
      title: item.at_css('title').content,
      pub_date: DateTime.parse(item.at_css('published').content),
    )
    ac.link = item.at_css('link').content if item.at_css('link')
    ac.description = item.at_css('description').content if item.at_css('description')
    ac.content = item.at_css('content').content if item.at_css('content')

    ac
  end

  def map_namespace(doc)
    doc.namespaces.keys.map do |key|
      key[key.index(':') + 1, key.length] if key.index(':')
    end
  end

  def transform_duration(ac)
    if ac.itunes_duration.index(':')
      split = ac.itunes_duration.split(':').reverse
      ac.duration_raw = split[0].to_i + (60 * (split[1].to_i + (60 * split[2].to_i)))
    else
      ac.duration_raw = ac.itunes_duration.to_i
      hours = ac.duration_raw / 3600
      minutes = (ac.duration_raw - (hours * 3600)) / 60
      seconds = ac.duration_raw - (hours * 3600) - (minutes * 60)

      hours = "0#{hours}" if hours < 10
      minutes = "0#{minutes}" if minutes < 10
      seconds = "0#{seconds}" if seconds < 10

      ac.itunes_duration = "#{hours}:#{minutes}:#{seconds}"
    end
    ac
  end
end

