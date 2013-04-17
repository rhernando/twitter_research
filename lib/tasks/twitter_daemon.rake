namespace :tweets do
  desc 'Daemon over tweets of users'

  task :watcher => :environment do
    ENV['RAILS_ENV'] = "development" if  !ENV['RAILS_ENV']

    yaml = YAML.load_file("config/mongoid.yml")
    env_info = yaml[ENV['RAILS_ENV']]
    unless env_info
      puts "Unknown environment"
      exit
    end

    Mongoid.configure do |config|
      config.from_hash(env_info)
    end

    require File.join(root, "config", "environment")



    client = TweetStream::Client.new

    daemon = TweetStream::Daemon.new("TweetNews", :log_output => true)
  end
end