#encoding: utf-8
require 'resque'

class NewsUpdate < Jobs::Base
  @queue = :news_update

  def self.perform(opts={})

    UpdateJob.update_news

  end

end