#encoding: utf-8
require 'resque'

class RetrievePreferences < Jobs::Base
  @queue = :user_tweets

  def self.perform(opts={})
    user = User.find(opts["user_id"])

    UserPreferences.load_timeline(user)

  end

end