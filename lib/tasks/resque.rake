require 'resque/tasks'
require 'resque_scheduler/tasks'

require "#{Rails.root}/config/environment"

namespace :resque do
  task :setup do
    ENV['QUEUE'] = '*'
  end
end
task 'resque:setup' => :environment
