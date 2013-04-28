class NewsController < ApplicationController
  def get_news
    offset = (params[:page] || 0).to_i * 10
    @page = params[:page]
    @total_news = current_user.user_newses.limit(15).skip(offset).order_by([:total_score, :desc])
    render :layout => false
  end

  def trends
    get_trends(current_user)
    render :layout => false
  end

  def trend
    @str_trend = params[:trend]
    arr_trends = Twitter.search(@str_trend).statuses
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

  def rate_news
    @lnew = LastNews.find params['idn']
    if @lnew.present?
      score = UserScoring.where(:last_news => @lnew, :user => current_user).first
      score = UserScoring.new(:last_news => @lnew, :user => current_user, :views => 0) if score.blank?
      if params['rating'].present?
        score.rate = params['rating'].to_i
      else
        score.views += 1
      end
      score.save
    end


    render :layout => false

  end
end
