require 'rails_helper'

RSpec.describe PledgesController, type: :controller do

  let(:campaign) { FactoryGirl.create(:campaign)}
  # We have this to generate a campaign instance so we have an id for our test methods to find
  # Recall that let(:arg) is a short form to write:
  # def arg
  #   @arg ||= FactoryGirl.create(:arg)
  # end
  let(:user) { FactoryGirl.create(:user) }

  describe "#new" do

    context "without a signed in user" do
      # To pass this context, we'll need a method to authenticate the user in our ApplicationController
      it "redirects to sign up page" do
        get :new, campaign_id: campaign.id
        expect(response).to redirect_to new_user_path
      end
    end

    context "with a signed in user" do
      # We set the session[:user_id] to a valid user id to emulate user being signed in
      before { login(user) }
      it "renders a new template" do
        get :new, campaign_id: campaign.id
        expect(response).to render_template(:new)
      end
      it "assigns a new pledge instance variable" do
        get :new, campaign_id: campaign.id
        expect(assigns(:pledge)).to be_a_new(Pledge)
      end
    end

  end

end
