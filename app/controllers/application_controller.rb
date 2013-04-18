class ApplicationController < ActionController::Base
  protect_from_forgery

  def best_news(user)
    return nil if user.blank?

    arr_news = user.array_sources
    total_news = {}
    arr_news.each do |n|
      next if UserSources.where(:url => /#{n.url}/, :user => user).first.present?

      # older news lost value
      total_news[n.id] = {:score => ((n.date_publish || Date.yesterday) - Date.today).to_i} unless total_news[n.id].present?
      total_news[n.id][:score] += UserSources.where(:source => n.source, :user => current_user).count

      total_news[n.id] = {:title => n.title, :source => n.source, :url => n.url, :date_publish => n.date_publish.strftime("%d/%m/%Y"),  :score => 1 + (total_news[n.id].try(:[], :score) || 0)}

      #current_user.collect_feeds if current_user.present?

    end

    total_news
  end

end
