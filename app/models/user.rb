class User < ActiveRecord::Base
  # attr_accessor :password, :password_confirmation
  # We added the line above to make a test fail in user_signups_spec.rb
  has_secure_password

  has_many :pledges, dependent: :nullify
  has_many :campaigns, dependent: :nullify

  validates :first_name, presence: true
  validates :last_name, presence: true, unless: :with_oauth?
  validates :email, presence: true, uniqueness: true, unless: :with_oauth?

  before_create :generate_api_key

  serialize :twitter_raw_data, Hash
  # serialize the Twitter as a Hash - in the database there is no way to store
  # Hashes (they are text or blobs) so we'll use a method from serialize

  geocoded_by :address
  after_validation :geocode

  def with_oauth?
    provider.present? && uid.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.find_or_create_with_twitter(omniauth_data)
    user = User.where(provider: 'twitter', uid: omniauth_data['uid']).first
    unless user
      full_name = omniauth_data['info']['name']
      user = User.create(first_name: extract_first_name(full_name),
                         last_name: extract_last_name(full_name),
                         provider: 'twitter',
                         uid: omniauth_data['uid'],
                         password: SecureRandom.hex(16),
                         twitter_token: omniauth_data['credentials']['token'],
                         twitter_secret: omniauth_data['credentials']['secret'],
                         twitter_raw_data: omniauth_data)
    end
    user
  end

  private

  def self.extract_first_name(full_name)
    if full_name.rindex(' ')
      full_name[0..full_name.rindex(' ') - 1]
    else
      full_name
    end
  end

  def self.extract_last_name(full_name)
    if full_name.rindex(' ')
      full_name.split.last
    else
      ''
    end
  end

  def generate_api_key
    begin
      self.api_key = SecureRandom.hex(32)
      # Recall that we use self here to reference the object (instance variable)
      # rather than the class. When we are setting a variable we use self. but
      # reading a variable it becomes redundant.
    end while User.exists?(api_key: api_key)
  end

  user = User.last
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = Rails.application.secrets.twitter_consumer_key
    config.consumer_secret     = Rails.application.secrets.twitter_consumer_key
    config.access_token        = user.twitter_token # from user
    config.access_token_secret = user.twitter_secret # from user
  end
end
