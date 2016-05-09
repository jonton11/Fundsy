class User < ActiveRecord::Base
  # attr_accessor :password, :password_confirmation
  # We added the line above to make a test fail in user_signups_spec.rb
  has_secure_password

  has_many :pledges, dependent: :nullify

  validates_presence_of :first_name, :last_name, :email
  validates :email, uniqueness: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
