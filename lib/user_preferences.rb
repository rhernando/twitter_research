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
  def self.load_timeline(user, twitter_id=nil)
    last_id = nil #user.user_sourceses.order_by([:id_tweet, :asc]).last.try(:id_tweet)
    tl = nil
    idt = 9999999999999999999

    #max_tweet =  (user.user_sourceses.order_by([:id_tweet, :asc]).last.try(:id_tweet) < idt)



    twitter_id ||= user.uid.to_i
    begin

      num_attempts = 0
      begin
        num_attempts += 1
        # retrieving user tweets
        params = {:include_rts => true, :count => 800, :since_id => last_id}
        tl = Twitter.user_timeline twitter_id, params.delete_if { |k, v| v.blank? || k == :screen_name }
        if tl.present?
          last_id = tl.first.id
          tl.each do |tweet|
            idt = tweet.id
            tweet.urls.each do |u|
              begin
                if user.present?
                  us = UserSources.where(:id_tweet => tweet.id).first
                  insert_url(u, tweet, user) unless us.present?
                else
                  us = FriendsSource.where(:id_tweet => tweet.id).first
                  return if us.present?
                  insert_url(u, tweet, nil, twitter_id) unless us.present?
                end
              rescue RuntimeError => e
                Rails.logger.warn "La url #{u.expanded_url} no es accesible. #{e}"
              end
            end
          end
        end
      rescue Twitter::Error::TooManyRequests => error
        Rails.logger.warn 'rate limit. waiting.....'
        if num_attempts <= MAX_ATTEMPTS
          sleep error.rate_limit.reset_in
          retry
        else
          raise
        end
      rescue Twitter::Error::ClientError => te
        # This explicit rescue will work
        puts te
        puts 'waiting '
        sleep 1000 #te.rate_limit.reset_in rescue retry
        puts "Rescued from Twitter::Error::ClientError : #{te}"
        retry
      end
    end while tl.present?
  end

  ## given a url, it retrieves tags and store them as user topics
  ## it also stores URL as a preferred source for the user
  def self.insert_url(url, tweet, user, friend_id = nil)
    uri = URI.parse(url.try(:expanded_url) || url)

    p url.try(:expanded_url) || url

    doc = Pismo::Document.new url.try(:expanded_url) || url rescue nil
    return unless doc.present?
    entities = entities_from_document(doc)


    # call dbpedia spottlight to retrieve tags
    # we use first 4000 chars because of the capacity limit of the url in rest services
    arr_ents = tags_from_entities(entities) || []

    arr_ents += doc.keywords.map { |x| x.first if x.first.length > 3 }.compact rescue []

    sf = SourceFeeds.find_or_create_by(:base_url => (uri.host.try(:downcase) || uri))
    if sf.feed_url.blank? && doc.feed.present?
      sf.feed_url = doc.feed
      sf.save
    end

    if friend_id.present?
      us = FriendsSource.new(:url => url.try(:expanded_url) || url, :id_tweet => tweet.try(:id), :source => (uri.host.try(:downcase) || uri), :tags => arr_ents, :user => user, :friend_id => friend_id)
      us.save
    else
      us = UserSources.new(:url => url.expanded_url, :id_tweet => tweet.id, :source => (uri.host.try(:downcase) || uri), :tags => arr_ents, :user => user)
      us.save
    end

  end


  ## rest petition to DBpedia spotlight to annotate document content
  def self.entities_from_document(doc)
    return [] unless doc.present?
    #only if needed
    #SPOTLIGHT_ACCESS.class.http_proxy '194.140.11.77', 80

    body_text = (doc.title || '') + ' ' + (doc.body || '') rescue nil

    body_text.present? ? (SPOTLIGHT_ACCESS.annotate body_text[0, MAX_LENGTH_DBS]) : [] rescue []
  end

  def self.tags_from_entities(entities)
    arr_ents = []

    if entities.present?
      entities.each do |ent|
        ent_type = ent["@types"].split(',').present? ? ent["@types"].split(',').first.split(':').last : nil
        # every entity has types and surfaceForm. we store first type and surfaceForm
        new_ent = {:name => ent["@surfaceForm"], :type => ent_type}

        arr_ents << new_ent
      end
      arr_ents
    end
  end

  def self.load_friends_tl(user, friends_ids)
    friends_ids.each do |fid|
      num_attempts = 0
      begin
        num_attempts += 1
        params = {:include_rts => true, :count => 20}
        tl = Twitter.user_timeline fid, params.delete_if { |k, v| v.blank? || k == :screen_name }
        if tl.present?
          p "Retrieving URL from #{tl.count} tweets of friend #{fid}"
          tl.each do |tweet|
            tweet.urls.each do |u|
              begin
                us = FriendsSource.where(:id_tweet => tweet.id, :id_friend => fid).first
                insert_url(u, tweet, user, fid) unless us.present?
              rescue RuntimeError => e
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
      rescue Twitter::Error::ClientError => te
        # This explicit rescue will work
        puts "Rescued from Twitter::Error::ClientError : #{te}"
        retry
      end

    end

  end
end