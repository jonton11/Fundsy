require 'rails_helper'

RSpec.describe Api::V1::CampaignsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:campaign) { FactoryGirl.create(:campaign) }
  # will only be created when called
  # let!(:campaign) { FactoryGirl.create(:campaign) }
  # will create no matter what
  # test either body or status
  render_views

  describe '#index' do
    context 'with no API key' do
      it 'responds with a 403 HTTP status code' do
        get :index, format: :json
        expect(response.status).to eq(403)
      end
    end
    context 'with API key' do
      it 'renders the campaigns title in the JSON response' do
        campaign
        get :index, api_key: user.api_key, format: :json
        expect(response.body).to have_text /#{campaign.title.titleize}/i
        puts '>>>>>>>>>>>>>'
        puts response.body
        puts response.status
        puts '>>>>>>>>>>>>>'
      end
    end
  end
  describe '#show' do
    context 'with api_key provided' do
      it 'renders a JSON with a campaign title' do
        get :show, id: campaign.id, format: :json, api_key: user.api_key
        response_body = JSON.parse(response.body)
        expect(response_body["campaign"]["title"]).to eq(campaign.title.titleize)
      end
    end
  end
end
