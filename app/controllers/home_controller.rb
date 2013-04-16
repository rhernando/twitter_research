class HomeController < ApplicationController

  def index

    arr_news = []
    UserSources.all.each do |us|
      arr_news += LastNews.any_in(tags: us.tags)
    end

    @total_news = {}
    arr_news.each do |n|
      # older news lost value
      @total_news[n.id] = {:score => ( (n.date_publish || Date.yesterday) - Date.today ).to_i} unless @total_news[n.id].present?

      @total_news[n.id] = {:title => n.title, :source => n.source, :url => n.url, :score => 1 + (@total_news[n.id].try(:[], :score) || 0) }
    end

  end
end
