require 'spec_helper'

describe Stack do
  describe "creating a new stack" do
    it "has a valid factory" do
      FactoryGirl.build(:stack).should be_valid
    end
    it "is invalid without a product name" do
      FactoryGirl.build(:stack, product_name: nil).should_not be_valid
    end
    it "is invalid without charge amount if charge type is fixed" do
      FactoryGirl.build(:stack, charge_amount: nil).should_not be_valid
    end
    it "is valid without charge amount if charge type is any" do
      FactoryGirl.build(:stack, charge_type: "any", charge_amount: nil).should be_valid
    end
  end
end
