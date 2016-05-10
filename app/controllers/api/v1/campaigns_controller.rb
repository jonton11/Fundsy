class Api::V1::CampaignsController < ApplicationController # :nodoc:
  def index
    @campaigns = Campaign.order(:created_at)
    # this will render /api/v1/views/index.json.jbuilder
    # render json: @campaigns
  end

  def show
    campaign = Campaign.find params[:id]
    render json: campaign
  end
end
