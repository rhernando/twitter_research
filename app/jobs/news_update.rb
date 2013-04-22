#encoding: utf-8
require 'resque'
#require 'resque_scheduler/tasks'

class NewsUpdate < Jobs::Base
  @queue = :news_update

  def self.perform(opts={})

    UpdateJob.update_news

  end

end