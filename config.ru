# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require 'resque/server'
require 'resque_scheduler'
require 'resque_scheduler/server'

AUTH_USER = "twitter"
AUTH_PASSWORD = "news"
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    username == AUTH_USER
    password == AUTH_PASSWORD
  end
end

run Rack::URLMap.new \
  "/"       => TwitterResearch::Application,
  "/resque" => Resque::Server.new

#run TwitterResearch::Application
