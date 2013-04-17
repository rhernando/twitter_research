module UpdateJob
  require 'open-uri'
  include UserPreferences

  SPOTLIGHT_ACCESS = DBpedia::Spotlight("http://spotlight.dbpedia.org/rest/")
  Rails.logger = Logger.new(STDOUT)

  ## check news from sources and store tags
  def self.update_news
    # update feeds accesed more than 10 minutes
    SourceFeeds.where(:last_access.lte => 10.minutes.ago, :last_access => nil).each do |sf|
      feed = Feedzirra::Feed.fetch_and_parse(sf.feed_url)
      sf.last_access = Time.now
      sf.save
      Rails.logger.info sf.feed_url
      feed.entries.each do |entry|
        news = LastNews.where(:url => entry.url).first
        if news.blank?
          news = LastNews.new(:source => sf.base_url, :url => entry.url, :date_publish => entry.published, :title => entry.title)
          doc = Pismo::Document.new entry.url
          arr_ents = UserPreferences.tags_from_entities(UserPreferences.entities_from_document(doc))
          news.tags = arr_ents

          news.save
        end

      end
    end

  end

  def self.update_score(user)

  end

end