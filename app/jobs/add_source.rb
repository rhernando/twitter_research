#encoding: utf-8
require 'resque'
#require 'resque_scheduler/tasks'

class AddSource < Jobs::Base
  @queue = :add_source

  def self.perform(opts={})

    url = opts["url"]
    uri = URI.parse(url)
    doc = Pismo::Document.new url rescue nil

    sf = SourceFeeds.find_or_create_by(:base_url => uri.host.downcase)
    if sf.feed_url.blank? && doc.feed.present?
      sf.feed_url = doc.feed
      sf.save
    end

  end

end