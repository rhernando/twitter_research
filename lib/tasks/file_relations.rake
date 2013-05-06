namespace :tweets do
  desc 'insert user relations from file'

  task :file_relations => :environment do
    f = File.new '/home/ruben/desarrollo/wsruby/twfiles/twitter_rv.net.1', 'r'
    while (line = f.gets)
      iduser = line.split(' ').last
      idfriend = line.split(' ').first

      new_user = TwitterUserData.where(:id_twitter => iduser).first

      next if new_user.blank?

      new_user.arr_friends ||= []
      new_user.arr_friends << idfriend.to_i
      new_user.arr_friends.uniq!

      new_user.save

    end

  end


end
