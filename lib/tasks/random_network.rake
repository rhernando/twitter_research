namespace :tweets do
  desc 'retrieve random user from twitter'

  task :rand_users => :environment do

    while true
      rnd_user = nil
      while rnd_user.blank?
        begin
          # random ID to retrieve a user
          id_look = Random.rand TwitterUserData.order_by([:id_twitter, :desc]).first.id_twitter.to_i
          rnd_user = Twitter.user id_look
        rescue Twitter::Error::TooManyRequests => error
          p error
          sleep error.rate_limit.reset_in
          retry
        rescue
          retry
        end
      end

      next if TwitterUserData.where(:id_twitter => rnd_user.id).first.present?

      user_data = TwitterUserData.create(
          :id_twitter => rnd_user.id,
          :name => rnd_user.name,
          :username => rnd_user.screen_name,
          :num_followers => rnd_user.followers_count,
          :num_friends => rnd_user.friends_count,
          :num_tweets => rnd_user.statuses_count,
          :born => rnd_user.created_at,
          :is_geo => rnd_user.geo_enabled
      )

      UserPreferences.load_timeline(nil, user_data.id_twitter.try(:to_i))

    end
  end

end


#TwitterUserData.order_by([:id_twitter, :desc]).first