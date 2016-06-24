class CampaignGoalJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # Do something later
    campaign = args[0]
    pledges_amount = campaign.pledges.sum(:amount)
    if pledges_amount >= campaign.goal
      Rails.logger.info ">>>>>>> #{Campaign Funded}"
    else
      Rails.logger.info ">>>>>>> #{Campaign UnFunded}"
    end
  end
end
