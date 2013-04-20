#encoding: utf-8
require 'resque'
#require 'resque_scheduler/tasks'

class NewsUpdate < Jobs::Base
  @queue = :news_update

  def self.perform(opts={})

    UpdateJob.update_news

    Resque.enqueue_in(10.minutes, NewsUpdate, *opts)


  end

end