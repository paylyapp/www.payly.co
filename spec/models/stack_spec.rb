require 'spec_helper'

describe Stack do
  before :each do
    @valid_stack = FactoryGirl.build(:stack)
  end

  describe "Seller" do
    it "should be able to create a One Time Payment Page" do
    end
    it "should be able to create a Digital Download Payment Page" do
    end
    it "should be able to create a Subscription Page" do
    end
  end

  it "has a valid factory" do
    @valid_stack.should be_valid
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
  it "returns true on sending_an_invoice? if send_invoice_email equals true" do
    stack = @valid_stack
    stack.send_invoice_email = false
    stack.sending_an_invoice?.should == false
    stack.send_invoice_email = true
    stack.sending_an_invoice?.should == true
  end
  it "returns true on charge_type_is_fixed? if charge_type equals fixed" do
    stack = @valid_stack
    stack.charge_type = "all"
    stack.charge_type_is_fixed?.should == false
    stack.charge_type = "fixed"
    stack.charge_type_is_fixed?.should == true
  end
  it "returns true on not_decommisioned? if archived is false" do
    stack = @valid_stack
    stack.archived = false
    stack.not_decommisioned?.should == true
    stack.archived = true
    stack.not_decommisioned?.should == false
  end
  it "should be able to create a Subscription page" do
  end
end
