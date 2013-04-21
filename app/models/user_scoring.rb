class UserScoring
  include Mongoid::Document

  belongs_to :user
  belongs_to :last_news

  field :views, :type => Integer
  field :rate, :type => Integer

end
