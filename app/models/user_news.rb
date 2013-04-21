class UserNews
  include Mongoid::Document

  belongs_to :user
  belongs_to :last_news

  field :feed_title, :type => String
  field :score, :type => Integer

  field :total_score, :type => Integer

  index({ total_score: 1 }, { unique: true, name: "total_score_index" })


end
