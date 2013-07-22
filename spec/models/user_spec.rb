require 'spec_helper'

describe User do
  it "should have relationship" do
    should have_many(:stacks)
    should have_many(:transactions)
  end
  
  it "should validate presence of" do
    should validate_presence_of :email
    should validate_presence_of :password
    should validate_presence_of :full_name
  end

  it "should validate uniqueness of" do
    should validate_uniqueness_of :email
  end

  it "should validate acceptance of" do
    should validate_acceptance_of :tos_agreement
  end
end