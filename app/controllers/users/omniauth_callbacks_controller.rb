class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    # Or alternatively,
    # raise ActionController::RoutingError.new('Not Found')
  end
  def twitter
    p 'Buscando tw User. ... .. .. .  . .'
    p params
    #p request.env
    p request.env["omniauth.auth"]
    p request.env["omniauth.auth"].keys
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"], current_user, request.remote_ip)

    # call proces to update database
    Resque.enqueue RetrievePreferences, {:user_id => @user.id}


    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to root_url #new_user_registration_url
    end
  end

  def providers
    ["twitter"]
  end
end
