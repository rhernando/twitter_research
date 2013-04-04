module UserPreferences

  MAX_TWEETS = 800
  MAX_ATTEMPTS = 3

  def self.load_timeline(user)
    last_id = nil

    tl = nil
    begin
      params = {:include_retweets => true, :count => 800, :since_id => last_id}

      num_attempts = 0
      begin
        num_attempts += 1
        tl = Twitter.home_timeline params.delete_if { |k, v| v.blank? }
        tl.each do |tweet|
          tweet.urls.each do |u|
            insert_url u
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

  def self.insert_url(url)
    us = UserSources.new(:url => url.expanded_url)
    us.save
  end

end