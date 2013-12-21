require 'spec_helper'

describe Transaction do
  it "should have relationship" do
    should belong_to(:customer)
    should belong_to(:stack)
  end
end