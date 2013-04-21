class ApplicationController < ActionController::Base
  protect_from_forgery

  def get_trends(user)
    @trends = []
    place = GeoPlanet::Place.search(user.address).first
    while @trends.blank? && place.present?
      woeid = place.woeid
      place = place.parent
      @trends = Twitter.trends(woeid) rescue nil
    end
  end

end
