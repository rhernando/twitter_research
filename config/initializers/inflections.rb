# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /^(ox)$/i, '\1en'
  inflect.singular /^(ox)en/i, '\1'

  inflect.irregular 'UserSources', 'UserSourceses'
  inflect.irregular 'user_sources', 'user_sourceses'

  inflect.irregular 'UserNews', 'UserNewses'
  inflect.irregular 'user_news', 'user_newses'

  inflect.irregular 'FriendNews', 'FriendNewses'
  inflect.irregular 'friend_news', 'friend_newses'

  inflect.irregular 'TwitterUserData', 'TwitterUserData'
  inflect.irregular 'twitter_user_data', 'twitter_user_data'

  inflect.uncountable %w( fish sheep )
end
#
# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.acronym 'RESTful'
# end
