class LastNews
  include Mongoid::Document

  field :tags, :type => Array
  field :url, type: String
  field :source, type: String
end
