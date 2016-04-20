class CampaignsController < ApplicationController
  before_action :find_campaign, only: [:show, :edit, :update, :destroy]

  def new
    @campaign = Campaign.new
  end

  def create

    campaign_params = params.require(:campaign).permit(:title, :body, :goal, :end_date)
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to campaign_path(@campaign), notice: "Campaing created!"
    else
      flash[:alert] = "Not saved!"
      render :new
    end
    # render nothing: true # if we render, we cannot redirect - will pass error
    # flash[:notice] = "Created!" -> we can also just add to line 10
  end

  def show
    @campaign = Campaign.find params[:id]
    # @pledge = Pledge.new - if we want in the campaign show page
    # We'll use external page for now
  end

  def index
    @campaigns = Campaign.order(:created_at)
  end

  def edit
    @campaign = Campaign.find params[:id]
  end

  def update
    @campaign = Campaign.find params[:id]
    campaign_params = params.require(:campaign).permit(:title, :body, :goal, :end_date)
    if @campaign.update campaign_params
      redirect_to campaign_path(@campaign), notice: "Updated!"
    else
      render :edit
    end
  end

  def destroy
    @campaign = Campaign.find params[:id]
    if @campaign.destroy
      redirect_to campaigns_path, notice: "Destroyed!"
    else
      render :index
    end
  end

  private

  def find_campaign
    @campaign = Campaign.find params[:id]
  end

  def campaign_params
    params.require(:campaign).permit(:title, :body, :goal, :end_date)
  end

end
