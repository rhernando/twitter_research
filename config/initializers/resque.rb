rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

# Load all job classes
Dir[Rails.root.join('app/jobs', '*.rb').to_s].each {|file| require file}

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
uri = URI.parse(resque_config[rails_env])

REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
Resque.redis = REDIS

Resque.redis.namespace = "resque:TwitterNews"



Resque.schedule = YAML.load_file(rails_root + '/config/resque_scheduler.yml')

