class HomeController < ApplicationController

  def index
    @map_loc = @json = current_user.to_gmaps4rails if current_user.present?
  end

end
