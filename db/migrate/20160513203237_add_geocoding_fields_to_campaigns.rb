class AddGeocodingFieldsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :address, :string
    add_column :campaigns, :longitude, :float
    add_column :campaigns, :latitude, :float
  end
end
