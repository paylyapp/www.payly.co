require 'spec_helper'

describe Transaction do
  it "should have relationship" do
    should belong_to(:stack)
    should belong_to(:subscription)
  end
end
