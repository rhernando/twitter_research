namespace :tweets do
  desc 'Get the network of a given user, with friends and followers'

  task :sources => :environment do
    ENV['RAILS_ENV'] = "development" if  !ENV['RAILS_ENV']
    Rails.logger = Logger.new(STDOUT)

    while true
      pos_us = Random.rand TwitterUserData.count
      tud = TwitterUserData.all[pos_us]

      Rails.logger.info "Retrieving tl from  user #{tud.id_twitter.try(:to_i)}."
      UserPreferences.load_timeline(nil, tud.id_twitter.try(:to_i)) unless FriendsSource.where(:friend_id => tud.id_twitter.try(:to_i)).first.present?
    end


    #Graphs.create_graph user_tw

  end


end