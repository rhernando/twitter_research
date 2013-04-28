module UpdateJob
  require 'open-uri'
  include UserPreferences

  SPOTLIGHT_ACCESS = DBpedia::Spotlight("http://spotlight.dbpedia.org/rest/")
  Rails.logger = Logger.new(STDOUT)

  ## check news from sources and store tags
  def self.update_news
    # update feeds accesed more than 60 minutes
    SourceFeeds.any_of({:last_access.lte => 240.minutes.ago}, {:last_access => nil}).each do |sf|
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

  MAX_ATTEMPTS = 5

  # http://www.ibm.com/developerworks/opensource/library/os-dataminingrubytwitter/
  # http://www.jstatsoft.org/v29/i04/paper
  def self.update_network!(update_db, user)
    Rails.logger.info "checking network for user #{user.name}(#{user.id_twitter.to_i})"
    num_attempts = 0
    cursor = "-1"

    if update_db || user.arr_followers.blank?
      while cursor != 0 do
        begin
          num_attempts += 1
          followers = Twitter.followers(user.id_twitter.to_i, :cursor => cursor)

          Rails.logger.info "Filling followers array"
          user.arr_followers = UpdateJob.get_users_array(followers.collection, user.arr_followers)

          user.save
          Rails.logger.info "Retrieved #{user.arr_followers.count} followers"

          num_attempts = 0
          cursor = followers.next_cursor
          num_attempts = 0
        rescue Twitter::Error::TooManyRequests => error
          if num_attempts <= MAX_ATTEMPTS
            Rails.logger.info error.rate_limit.inspect
            Rails.logger.info "Waiting . rate limit"
            sleep error.rate_limit.reset_in
            retry
          else
            raise
          end
        end
      end
    end

    Rails.logger.info "followers updated"

    num_attempts = 0
    cursor = "-1"
    if update_db || user.arr_friends.blank?

      while cursor != 0 do
        begin
          num_attempts += 1
          friends = Twitter.friends(user.id_twitter.to_i, :cursor => cursor)

          Rails.logger.info "Filling friends array"
          user.arr_friends = UpdateJob.get_users_array(friends.collection, user.arr_friends)

          Rails.logger.info "Retrieved #{user.arr_friends.count} friends"

          user.save
          cursor = friends.next_cursor
          num_attempts = 0
        rescue Twitter::Error::TooManyRequests => error
          if num_attempts <= MAX_ATTEMPTS
            Rails.logger.info error.rate_limit.inspect
            Rails.logger.info "Waiting . rate limit"
            sleep error.rate_limit.reset_in
            retry
          else
            raise
          end
        end
      end

    end
    Rails.logger.info "friends updated"

    user
  end

  def self.get_users_array(twitusers, arr_follow = [])
    arr_follow = [] unless arr_follow.kind_of?(Array)
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

      arr_follow |= [follower.id]
      Rails.logger.info "ARRAY #{arr_follow}"
    end
    arr_follow
  end
end