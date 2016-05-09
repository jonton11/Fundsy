require 'rails_helper'

RSpec.feature 'Campaigns', type: :feature do
  describe 'Listings Page' do
    it 'contains a text: All Campaigns' do
      # Visit is a method from Capybara that emulates visiting a page from RSpec
      visit campaigns_path
      # page is an special object from capybara that we can do
      # matching on - displays as HTML page
      expect(page).to have_text('All Campaigns')
    end
    it 'contains an h2 element with text: Recent Campaigns' do
      visit campaigns_path
      # have_selector here is another matcher
      expect(page).to have_selector 'h2', text: 'Recent Campaigns'
    end
    it "displays a campaign's title on the page" do
      c = FactoryGirl.create(:campaign)
      visit campaigns_path
      expect(page).to have_text /#{c.title}/i
    end
  end
end
