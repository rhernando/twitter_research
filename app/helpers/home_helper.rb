module HomeHelper
  def have_seen(user, lnew)
    views = user.user_scorings.where(:last_news => lnew).first.try :views

    views.present? && views > 0
  end

  def class_btn(user, lnew)
    rating = user.user_scorings.where(:last_news => lnew).first.try :rate
    if rating.present?
      return 'btn-success' if rating > 3
      return 'btn-danger' if rating < 3
    end

    have_seen(current_user, lnew)? 'btn-info' : 'btn-primary'

  end

  def score(user, lnew)
    user.user_scorings.where(:last_news => lnew).first.try :rate
  end
end
