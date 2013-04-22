class LastNews
  include Mongoid::Document

  belongs_to :source_feeds
  has_many :user_scorings

  field :tags, :type => Array
  field :url, type: String
  field :source, type: String
  field :date_publish, :type => Date
  field :title, type: String
  field :lede, type: String


  index({ url: 1 }, { unique: true, name: "url_ln_index" })
  index({ date_publish: 1 }, { unique: false, name: "date_publish_index" })
end
