class Reward < ActiveRecord::Base # :nodoc:
  belongs_to :campaign

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
end
