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

  def self.update_network!(update_db, user)
    begin
      if update_db || user.arr_followers.blank?
        followers = Twitter.followers(user.uid.to_i)
        user.arr_followers = UpdateJob.get_users_array(followers)
        user.save
        Rails.logger.info "Retrieved #{user.arr_followers.count} followers"
      end
    rescue Twitter::Error::TooManyRequests => error
      if num_attempts <= MAX_ATTEMPTS
        sleep error.rate_limit.reset_in
        retry
      else
        raise
      end
    end


    begin
      if update_db || auser.arr_friends.blank?
        friends = Twitter.friends(user.uid.to_i)
        user.arr_friends = UpdateJob.get_users_array(friends)
        user.save
        Rails.logger.info "Retrieved #{user.arr_friends.count} friends"
      end
    rescue Twitter::Error::TooManyRequests => error
      if num_attempts <= MAX_ATTEMPTS
        sleep error.rate_limit.reset_in
        retry
      else
        raise
      end
    end

    user
  end

  def self.get_users_array(twitusers)
    arr_follow = []
    twitusers.each do |f|
      follower = TwitterUserData.where(:id_twitter => f.id.to_s).first
      follower = TwitterUserData.new(:id_twitter => f.id.to_s) if follower.blank?

      follower.update_attributes(
          :name => f.name,
          :num_followers => f.followers_count,
          :num_friends => f.friends_count,
          :num_tweets => f.statuses_count,
          :born => f.created_at,
          :is_geo => f.geo_enabled)
      follower.save

      Rails.logger.info "retrieved user #{f.name}"

      arr_follow << follower.id
    end

  end
end