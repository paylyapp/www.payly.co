require 'spec_helper'

describe User do
  it "has a valid factory" do
    @valid_user = FactoryGirl.create(:user)
    @valid_user.should be_valid
  end

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

  it "should validate uniqueness of username if is nil or blank" do
    @valid_user = FactoryGirl.create(:user)
    @another_valid_user = FactoryGirl.build(:user, :email => 'tim.j.gleeson@gmail.com')
    @valid_user.should be_valid
    @another_valid_user.should be_valid
  end

  it "should validate uniqueness of username if not blank or nil" do
    @valid_user = FactoryGirl.create(:user, :username => 'test')
    @another_valid_user = FactoryGirl.build(:user, :email => 'tim.j.gleeson@gmail.com', :username => 'test')
    @valid_user.should be_valid
    @another_valid_user.should_not be_valid
  end

  it "should validate acceptance of" do
    should validate_acceptance_of :tos_agreement
  end

  describe "Subsciptions" do
    it "should list all active subscriptions" do
    end
  end
  describe "Subsciption" do
    it "should list the all transactions" do
    end
  end
end