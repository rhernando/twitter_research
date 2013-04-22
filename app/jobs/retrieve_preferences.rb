#encoding: utf-8
require 'resque'

class RetrievePreferences < Jobs::Base
  @queue = :user_tweets

  def self.perform(opts={})
    user = User.find(opts["user_id"])

    UserPreferences.load_timeline(user)

    p 'updating friends sources'
    some_friends = Twitter.friend_ids(user.uid.to_i, :skip_status => 1).ids.first(10)
    UserPreferences.load_friends_tl(user, some_friends)

  end

end