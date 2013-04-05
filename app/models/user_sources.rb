class UserSources
  include Mongoid::Document

  field :url, type: String
  field :source, type: String

  field :id_tweet, type: Integer

  field :tags, :type => Array
end