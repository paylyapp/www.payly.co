require 'spec_helper'

describe Stack do
  it "has a valid factory" do
    FactoryGirl.create(:stack).should be_valid
  end
  it "is invalid without a product name"
  it "is invalid without a description"
  it "is invalid without a seller name"
  it "is invalid without a seller email"
  it "is invalid without charge amount if charge type is fixed" do
    FactoryGirl.create(:stack, charge_amount: nil).should_not be_valid
  end
  it "is valid without charge amount if charge type is any" do
    FactoryGirl.create(:stack, charge_type: "any", charge_amount: nil).should be_valid
  end
end
