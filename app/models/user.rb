class User
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  geocoded_by :ip_address # can also be an IP address
  after_validation :geocode # auto-fetch coordinates

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, #:validatable,
         :omniauthable,
         :omniauth_providers => [:twitter]


  ## Database authenticatable
  field :email, :type => String
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token, :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count, :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at, :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip, :type => String

  field :provider, :type => String
  field :uid, :type => String

  field :name, :type => String

  field :coordinates, :type => Array
  field :ip_address
  field :address, :type => String

  has_many :user_sourceses, dependent: :delete
  has_many :user_scorings
  has_many :user_newses
  has_many :friends_sources


  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil, location = nil)
    p 'in user'
    p auth
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

    unless user
      user = User.create(name: auth.extra.raw_info.name,
                         provider: auth.provider,
                         uid: auth.uid,
                         email: auth.info.email || auth.extra.raw_info.screen_name,
                         password: Devise.friendly_token[0, 20]
      )

      user.save
    end

    user.ip_address = location == "127.0.0.1" ? "150.244.56.51" : location
    new_address = Geocoder.search(user.ip_address).first.try(:address)
    user.address = new_address if new_address.present?

    user.save

    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.twitter_data"] && session["devise.twitter_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end


  def array_sources
    arr_news = []
    self.user_sourceses.each do |us|
      arr_news += LastNews.where(:date_publish.gte => 5.days.ago).any_in(tags: us.tags)
    end

    arr_news
  end

end
