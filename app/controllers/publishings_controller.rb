class PublishingsController < ApplicationController # :nodoc:
  before_action :authenticate_user!
  def update
    campaign = Campaign.find(params[:campaign_id])
    campaign.publish!
    redirect_to campaign_path(campaign), notice: 'Campaign has been published!'
  end
end
