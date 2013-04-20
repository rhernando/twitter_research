class NewsController < ApplicationController
  def get_news
    @total_news = best_news(current_user)
    render :layout => false
  end

  def trends
    get_trends(current_user)
    render :layout => false
  end

  def trend
    str_trend = params[:trend]
    arr_trends = Twitter.search(str_trend).statuses
    @news_trend = []

    arr_trends.each do |tweet|
      tweet.urls.each do |url|
        begin
          doc = Pismo::Document.new url.expanded_url rescue nil
          if doc.present?
            @news_trend << doc
            Resque.enqueue AddSource, {:url => url.expanded_url}
          end
        rescue RuntimeError => e
          Rails.logger.warn "La url #{url.expanded_url} no es accesible. #{e}"
        end
      end


    end
    render :layout => false

  end
end
