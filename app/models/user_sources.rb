class UserSources
  include Mongoid::Document

  field :url, type: String
  field :source, type: String

  field :tags, :type => Array
end
