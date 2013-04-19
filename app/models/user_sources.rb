class UserSources
  include Mongoid::Document

  belongs_to :user

  field :url, type: String
  field :source, type: String
  field :id_tweet, type: Integer
  field :tags, :type => Array

  index({ id_tweet: 1 }, { unique: true, name: "id_tweet_index" })

end
