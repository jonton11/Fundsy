class Campaign < ActiveRecord::Base # :nodoc:
  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true, numericality: { greater_than: 10 }

  has_many :pledges, dependent: :destroy
  has_many :rewards, dependent: :destroy
  accepts_nested_attributes_for :rewards,
                                reject_if:     :all_blank,
                                allow_destroy: true

  belongs_to :user

  geocoded_by :address
  after_validation :geocode

  include AASM

  aasm whiny_transitions: false do
    state :draft, initial: true
    state :published
    state :canceled
    state :funded
    state :unfunded

    event :publish do
      transitions from: :draft, to: :published
    end
    event :fund do
      transitions from: :published, to: :funded
    end
    event :unfund do
      transitions from: :published, to: :unfunded
    end
    event :cancel do
      transitions from: [:draft, :published], to: :canceled
    end
  end

  def upcased_title
    title.upcase
  end
end
