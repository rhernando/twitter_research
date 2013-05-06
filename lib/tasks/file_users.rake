namespace :tweets do
  desc 'insert user from file'

  task :file_users => :environment do
    f = File.new '/home/ruben/desarrollo/wsruby/twfiles/numeric2screen.txt', 'r'
    while (line = f.gets)
      iduser = line.split(' ').first
      username = line.split(' ')[1..-1].join ' '

      new_user = TwitterUserData.where(:id_twitter => iduser).first
      new_user = TwitterUserData.new(:id_twitter => iduser) if new_user.blank?

      new_user.username = username
      new_user.save

    end

  end


end
