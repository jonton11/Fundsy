class Campaign < ActiveRecord::Base

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true, numericality: {greater_than: 10}

  has_many :pledges, dependent: :destroy
  belongs_to :user

  geocoded_by :address
  after_validation :geocode
  def upcased_title
    title.upcase
  end

end
