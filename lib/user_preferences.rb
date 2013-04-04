module UserPreferences
  require 'open-uri'


  MAX_TWEETS = 800
  MAX_ATTEMPTS = 3

  def self.load_timeline(user)
    last_id = nil

    tl = nil
    begin

      num_attempts = 0
      begin
        num_attempts += 1
        params = {:include_rts => true, :count => 800, :since_id => last_id}
        p params
        tl = Twitter.user_timeline user.uid.to_i, params.delete_if { |k, v| v.blank? || k == :screen_name }
        if tl.present?
          last_id = tl.first.id
          tl.each do |tweet|
            tweet.urls.each do |u|
              insert_url u, tweet
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

  def self.insert_url(url, tweet)
    uri = URI.parse(url.expanded_url)
    doc = Nokogiri::HTML(open(url))

    us = UserSources.new(:url => url.expanded_url, :id_tweet => tweet.id, :source => uri.host.downcase)
    us.save
  end

end