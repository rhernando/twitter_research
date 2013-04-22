#encoding: utf-8
require 'resque'

class UpdateScore < Jobs::Base
  @queue = :update_score
  Rails.logger = Logger.new(STDOUT)


  def self.perform(opts={})

    User.all.each do |user|
      Rails.logger.info "Updating news for User user #{user.name}"

      arr_news = LastNews.nin(:id => user.user_newses.to_a.map { |x| x.last_news.id })
      arr_news.each do |ln|
        next if UserSources.where(:url => /#{ln.url}/, :user => user).first.present?

        un = UserNews.new(:last_news => ln, :user => user, :score => 0, :feed_title => ln.source_feeds.try(:title), :total_score => 0)

        un.score += user.user_sourceses.any_in(tags: ln.tags).count
        un.score += UserSources.where(:source => ln.source, :user => user).count

        un.total_score = un.score + ((ln.date_publish || Date.yesterday) - Date.today).to_i

        un.save

        Rails.logger.info "Updated #{ln.title} with score #{un.score}"
      end

      arr_news = LastNews.nin(:id => user.user_newses.to_a.map { |x| x.last_news.id })
      arr_news.each do |ln|
        updatable = UserNews.where(:last_news => ln)
        updatable.each do |un|
          un.total_score = un.score + ((ln.date_publish || Date.yesterday) - Date.today).to_i
          un.save
        end
      end

    end

    Resque.enqueue_in(10.minutes, UpdateScore, *opts)


  end

end