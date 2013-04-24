#encoding: utf-8
require 'resque'

class UpdateScore < Jobs::Base
  @queue = :update_score
  Rails.logger = Logger.new(STDOUT)


  def self.perform(opts={})

    User.all.each do |user|
      Rails.logger.info "Updating news for User user #{user.name}"

      LastNews.all.each do |ln|
        next if UserSources.where(:url => /#{ln.url}/, :user => user).first.present?

        un = UserNews.where(:last_news => ln, :user => user).first
        un = UserNews.new(:last_news => ln, :user => user, :score => 0, :feed_title => ln.source_feeds.try(:title), :total_score => 0) if un.blank?

        un.score += user.user_sourceses.any_in(tags: ln.tags).count
        un.score += UserSources.where(:source => ln.source, :user => user).count

        un.score += user.friends_sources.any_in(tags: ln.tags).count
        un.score += FriendsSource.where(:source => ln.source, :user => user).count

        u_score = UserScoring.where(:last_news => ln, :user => user).first
        if u_score.present?
          un.score += u_score.views
          un.score += (u_score.rate - 3) * 2 if u_score.rate.present?
        end

        un.total_score = un.score + ((ln.date_publish || Date.yesterday) - Date.today).to_i

        un.save

        Rails.logger.info "Updated #{ln.title} with score #{un.score}"
      end

    end

  end

end