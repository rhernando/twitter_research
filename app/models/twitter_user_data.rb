class TwitterUserData
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :friend_newses

  field :id_twitter, :type => String
  field :name, :type => String
  field :username, :type => String

  field :num_followers, :type => Integer
  field :num_friends, :type => Integer
  field :num_tweets, :type => Integer

  field :born, :type => Date

  field :is_geo, :type => Boolean

  field :arr_followers, :type => Array
  field :arr_friends, :type => Array


  index({ id_twitter: 1 }, { unique: true, name: "u_ id_twitter_index" })
  index({ username: 1 }, { unique: true, name: "username_tud_index" })


end


#@attrs={
# :id=>1080301206,
# :id_str=>"1080301206",
# :name=>"jobision",
# :screen_name=>"jobision",
# :location=>"",
# :followers_count=>1537,
# :friends_count=>1971,
# :listed_count=>28,
# :created_at=>"Fri Jan 11 17:06:25 +0000 2013",
# :favourites_count=>0,
# :utc_offset=>nil,
# :time_zone=>nil,
# :geo_enabled=>false,
# :verified=>false,
# :statuses_count=>50,
# :lang=>"es",
# >
