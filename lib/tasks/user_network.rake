namespace :tweets do
  desc 'Get the network of a given user, with friends and followers'

  task :network => :environment do
    ENV['RAILS_ENV'] = "development" if  !ENV['RAILS_ENV']
    Rails.logger = Logger.new(STDOUT)

    MAX_ATTEMPTS = 3

    user_name = ENV['USERNAME']
    update_db = ENV['UPDATE'].present? && ENV['UPDATE'] == '1'
    user = User.find_by(:email => user_name)

    Rails.logger.info "Updating network for user #{user.name}(#{user.email})"

    UpdateJob.update_network!(update_db, user)

    user.arr_followers.each do |fid|

      UpdateJob.update_network!(update_db, user)
    end



  end
end