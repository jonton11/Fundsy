require 'rails_helper'

RSpec.describe Pledge, type: :model do

  describe "validations" do
    it "requires an amount" do
      p = Pledge.new(FactoryGirl.attributes_for(:pledge).merge({amount: nil}))
      expect(p).to be_invalid
    end
    it "requires an amount 1 or greater" do
      p = Pledge.new(FactoryGirl.attributes_for(:pledge).merge({amount: -1}))
      expect(p).to be_invalid
    end
  end

end
