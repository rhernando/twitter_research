class FriendNews
  include Mongoid::Document

  belongs_to :twitter_user_data
  belongs_to :last_news

  field :feed_title, :type => String
  field :score, :type => Integer

  field :total_score, :type => Integer

  index({ total_score: 1 }, { unique: true, name: "total_score_f_index" })

end
