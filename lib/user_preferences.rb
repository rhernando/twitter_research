## module to work with user tweets and store topic preferences
module UserPreferences
  require 'open-uri'

  SPOTLIGHT_ACCESS = DBpedia::Spotlight("http://spotlight.dbpedia.org/rest/")
  Rails.logger = Logger.new(STDOUT)

  MAX_TWEETS = 800
  MAX_ATTEMPTS = 3
  MAX_LENGTH_DBS = 4000

  ## background process that will retrieve all user tweets, searching for URLs
  ## for each URL, it requests the page content and call DBpedia Spotlight to annottate tags
  ## then it saves tags into user preferences
  def self.load_timeline(user)
    last_id = nil

    tl = nil
    begin

      num_attempts = 0
      begin
        num_attempts += 1
        # retrieving user tweets
        params = {:include_rts => true, :count => 800, :since_id => last_id}
        tl = Twitter.user_timeline user.uid.to_i, params.delete_if { |k, v| v.blank? || k == :screen_name }
        if tl.present?
          last_id = tl.first.id
          tl.each do |tweet|
            tweet.urls.each do |u|
              begin
                insert_url u, tweet
              rescue => e
                Rails.logger.warn "La url #{u.expanded_url} no es accesible. #{e}"
              end
            end
          end
        end
      rescue Twitter::Error::TooManyRequests => error
        if num_attempts <= MAX_ATTEMPTS
          sleep error.rate_limit.reset_in
          retry
        else
          raise
        end
      end
    end while tl.present?
  end

  ## given a url, it retrieves tags and store them as user topics
  ## it also stores URL as a preferred source for the user
  def self.insert_url(url, tweet)
    uri = URI.parse(url.expanded_url)

    doc = Pismo::Document.new url.expanded_url
    entities = entities_from_document(doc)


    # call dbpedia spottlight to retrieve tags
    # we use first 4000 chars because of the capacity limit of the url in rest services
    arr_ents = tags_from_entities(entities)

    sf = SourceFeeds.find_or_create_by(:base_url => uri.host.downcase)
    if sf.feed_url.blank? && doc.feed.present?
      sf.feed_url = doc.feed
      sf.save
    end


    us = UserSources.new(:url => url.expanded_url, :id_tweet => tweet.id, :source => uri.host.downcase, :tags => arr_ents)
    us.save
  end

  ## check into news from sources and store tags
  def update_news
    SourceFeeds.all.each do |sf|
      feed = Feedzirra::Feed.fetch_and_parse(sf.feed_url)
      feed.entries.each do |entry|
        news = LastNews.new(:source => sf.base_url, :url => entry.url)
        doc = Pismo::Document.new entry.url
        arr_ents = tags_from_entities(entities_from_document(doc))
        news.tags = arr_ents

        news.save
      end
    end

  end

  ## rest petition to DBpedia spotlight to annotate document content
  def entities_from_document(doc)

    #only if needed
    SPOTLIGHT_ACCESS.class.http_proxy '194.140.11.77', 80

    body_text = doc.title + ' ' + doc.body

    body_text.present? ? SPOTLIGHT_ACCESS.annotate body_text[0, MAX_LENGTH_DBS] : []
  end

  def tags_from_entities(entities)
    arr_ents = []

    entities.each do |ent|
      ent_type = ent["@types"].split(',').present? ? ent["@types"].split(',').first.split(':').last : nil
      # every entity has types and surfaceForm. we store first type and surfaceForm
      new_ent = {:name => ent["@surfaceForm"], :type => ent_type}

      arr_ents << new_ent
    end
    arr_ents
  end
end