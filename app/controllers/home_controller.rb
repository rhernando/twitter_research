class HomeController < ApplicationController

  def index

  end

  def get_news
    @total_news = best_news(current_user)
    render :layout => false
  end
end
