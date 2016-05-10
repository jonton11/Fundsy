class User < ActiveRecord::Base
  # attr_accessor :password, :password_confirmation
  # We added the line above to make a test fail in user_signups_spec.rb
  has_secure_password

  has_many :pledges, dependent: :nullify
  has_many :campaigns, dependent: :nullify

  validates_presence_of :first_name, :last_name, :email
  validates :email, uniqueness: true

  before_create :generate_api_key

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def generate_api_key
    begin
      self.api_key = SecureRandom.hex(32)
      # Recall that we use self here to reference the object (instance variable)
      # rather than the class. When we are setting a variable we use self. but
      # reading a variable it becomes redundant.
    end while User.exists?(api_key: api_key)
  end
end
