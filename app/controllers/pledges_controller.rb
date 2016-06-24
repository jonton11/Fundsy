class PledgesController < ApplicationController # :nodoc:
  before_action :authenticate_user!
  before_action :find_campaign

  def new
    @pledge = Pledge.new
  end

  def create
    @pledge          = Pledge.new pledge_params
    @pledge.user     = current_user
    @pledge.campaign = @campaign
    if @pledge.save
      redirect_to new_pledge_payment_path(@pledge), notice: 'Pledged'
    else
      render :new
    end
  end

  private

  def pledge_params
    params.require(:pledge).permit(:amount)
  end

  def find_campaign
    @campaign = Campaign.find params[:campaign_id]
  end
end
