namespace :tweets do
  desc 'Get the network of a given user, with friends and followers'

  task :network => :environment do
    ENV['RAILS_ENV'] = "development" if  !ENV['RAILS_ENV']
    Rails.logger = Logger.new(STDOUT)


    user_name = ENV['USERNAME']
    update_db = ENV['UPDATE'].present? && ENV['UPDATE'] == '1'
    user = User.find_by(:email => user_name)

    Rails.logger.info "Updating network for user #{user.name}(#{user.email})"

    user_tw = TwitterUserData.where(:id_twitter => user.uid.to_i).first
    user_tw = TwitterUserData.new(:id_twitter => user.uid.to_i) if user_tw.blank?

    UpdateJob.update_network!(update_db, user_tw)


    user_tw.arr_followers.each do |fid|
      fus = TwitterUserData.find(fid)
      UpdateJob.update_network!(update_db, fus) if fus.present?
    end


    Graphs.create_graph user_tw

  end


end