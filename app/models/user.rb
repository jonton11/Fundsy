class User < ActiveRecord::Base
  # attr_accessor :password
  has_secure_password

  has_many :pledges, dependent: :nullify

  validates_presence_of :first_name, :last_name, :email
  #validates_presence_of :last_name, :email
  validates :email, uniqueness: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
