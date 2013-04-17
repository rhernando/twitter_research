class SourceFeeds
  include Mongoid::Document
  field :base_url, type: String
  field :feed_url, type: String
  field :last_access, type: DateTime
end
