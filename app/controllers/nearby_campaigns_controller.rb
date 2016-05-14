class NearbyCampaignsController < ApplicationController
  before_action :authenticate_user!

  def index
    coordinates = [ current_user.latitude, current_user.longitude]
    @campaigns = Campaign.near(coordinates, 40, units: :km)
    @markers   = Gmaps4rails.build_markers(@campaigns) do |campaign, marker|
      marker.lat campaign.latitude
      marker.lng campaign.longitude
    end
  end
end
