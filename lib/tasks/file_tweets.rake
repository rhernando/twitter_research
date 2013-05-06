namespace :tweets do
  desc 'insert user tweets with URL from file'

  task :url_users => :environment do
    f = File.new '/home/ruben/desarrollo/wsruby/twfiles/tweets', 'r'
    fout = File.new '/home/ruben/desarrollo/wsruby/twfiles/tweets_unknown', 'w'

    while (line = f.gets)
      username = line.split(' ')[1]
      txt_tweet = line.split(' ')[2..-1].join('')

      tw_user = TwitterUserData.where(:username => username).first



      if tw_user.blank?
        fout.puts line
        next
      end

      exp_tw = /https?:\/\/[\S]+/.match txt_tweet
      i = 0
      while exp_tw.present? && (url = exp_tw[i])
        i+=1
        UserPreferences.insert_url(url, nil, nil, tw_user.id_twitter)

      end

    end

  end


end
