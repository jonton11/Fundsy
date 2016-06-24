class CampaignsController < ApplicationController # :nodoc:
  # Redirect flow (render etc.) OR
  # Set up variables => call via service object
  # Service objects are classes => use in controllers
  # Helper methods => methods called in view
  before_action :find_campaign, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:show, :index]

  def new
    @campaign = Campaign.new
    3.times { @campaign.rewards.build }
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.user = current_user
    if @campaign.save
      CampaignGoalJob.set(wait_until: @campaign.end_date).perform_later(@campaign)
      redirect_to campaign_path(@campaign), notice: 'Campaign created!'
    else
      gen_count = 3 - @campaign.rewards.size
      # Why .size()? = because using count will use the count aggregate method
      # in SQL via ActiveRecord (there is no db record yet)
      gen_count.times { @campaign.rewards.build }
      flash[:alert] = 'Problem!'
      render :new
    end
    # render nothing: true # if we render, we cannot redirect - will pass error
    # flash[:notice] = 'Created!' -> we can also just add to line 10
  end

  def show
    # @pledge = Pledge.new - if we want in the campaign show page
    # We'll use external page for now
  end

  def index
    @campaigns = Campaign.includes(:pledges).order(:created_at).references(:pledges)
    respond_to do |format|
      format.json { render json: @campaigns.to_json }
      format.html { render }
      # note that render json: will automatically call .to_json method to the
      # argument passed
    end
  end

  def edit
  end

  def update
    if @campaign.update campaign_params
      redirect_to campaign_path(@campaign), notice: 'Updated!'
    else
      render :edit
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: 'Deleted!'
  end

  private

  def find_campaign
    @campaign = Campaign.find(params[:id]).decorate
  end

  def campaign_params
    params.require(:campaign).permit(:title, :body, :goal, :end_date, :address,
                                    {rewards_attributes: [:amount, :description, :id, :_destroy]})
  end
end
