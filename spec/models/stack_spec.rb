require 'spec_helper'

describe Stack do
  before :each do
    @valid_stack = FactoryGirl.build(:stack)
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

  it "returns true has_surcharge if all surcharge fields are entered" do
    stack = @valid_stack
    stack.require_surcharge = true
    stack.surcharge_value = 10
    stack.surcharge_unit = 'percentage'
    stack.has_surcharge?.should == true
  end
  it "returns false has_surcharge if any of the surcharge fields are not entered" do
    stack = @valid_stack
    stack.require_surcharge = false
    stack.has_surcharge?.should == false
  end
  it "returns false has_surcharge if any of the surcharge fields are not entered" do
    stack = @valid_stack
    stack.require_surcharge = true
    stack.surcharge_value = 10
    stack.has_surcharge?.should == false
  end

  it "returns true has_shipping if all surcharge fields are entered" do
    stack = @valid_stack
    stack.require_shipping = true
    stack.shipping_cost_value = [10.95, 29.95]
    stack.shipping_cost_term = ['Domestic', 'International']
    stack.has_shipping?.should == true
  end
  it "returns false has_shipping if any of the surcharge fields are not entered" do
    stack = @valid_stack
    stack.require_shipping = false
    stack.has_surcharge?.should == false
  end
  it "returns false has_shipping if any of the surcharge fields are not entered" do
    stack = @valid_stack
    stack.require_shipping = true
    stack.shipping_cost_value = [10.95, 29.95]
    stack.has_surcharge?.should == false
  end
end
