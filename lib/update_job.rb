module UpdateJob
  require 'open-uri'
  include UserPreferences

  SPOTLIGHT_ACCESS = DBpedia::Spotlight("http://spotlight.dbpedia.org/rest/")
  Rails.logger = Logger.new(STDOUT)

  ## check news from sources and store tags
  def self.update_news
    # update feeds accesed more than 60 minutes
    SourceFeeds.any_of({:last_access.lte => 60.minutes.ago}, {:last_access => nil}).each do |sf|
      feed = Feedzirra::Feed.fetch_and_parse(sf.feed_url)
      sf.last_access = Time.now
      sf.title = feed.title rescue nil
      sf.save
      Rails.logger.info sf.feed_url
      if (feed.try(:entries) rescue nil).present?
        feed.entries.each do |entry|
          news = LastNews.where(:url => entry.url).first
          if news.blank?
            news = LastNews.new(:source => sf.base_url, :url => entry.url, :date_publish => entry.published, :title => entry.title)
            doc = Pismo::Document.new entry.url rescue nil
            next if doc.blank?
            arr_ents = UserPreferences.tags_from_entities(UserPreferences.entities_from_document(doc)) || []
            news.tags = arr_ents
            news.tags += doc.keywords.map { |x| x.first if x.first.length > 3 }.compact rescue []
            news.lede = doc.lede rescue ''
            news.save
          end

        end
      end
    end

  end

  def self.update_score(user)

  end

end