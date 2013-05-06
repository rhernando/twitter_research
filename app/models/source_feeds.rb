class SourceFeeds
  include Mongoid::Document
  field :base_url, type: String
  field :feed_url, type: String
  field :last_access, type: DateTime
  field :title, type: String


  index({ last_access: 1 }, { unique: false, name: "last_access_index" })

end
