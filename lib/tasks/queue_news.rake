namespace :tweets do
  desc 'place a job to update news'

  task :updater => :environment do
    ENV['RAILS_ENV'] = "development" if  !ENV['RAILS_ENV']

    Resque.enqueue NewsUpdate

  end
end