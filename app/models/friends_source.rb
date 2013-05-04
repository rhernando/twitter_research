class FriendsSource
  include Mongoid::Document

  belongs_to :user

  field :url, type: String
  field :source, type: String
  field :id_tweet, type: Integer
  field :tags, :type => Array

  field :friend_id, type: Integer

  index({ id_tweet: 1 }, { unique: true, name: "id_tweet_fs_index" })
  index({ friend_id: 1 }, { unique: false, name: "id_friend_fs_index" })

end
