require 'spec_helper'

describe User do
  it "has a valid factory" do
    @valid_user = FactoryGirl.create(:user)
    @valid_user.should be_valid

    entity = Entity.find_by_user_token(@valid_user.user_token)
    entity.nil?.should == false
    entity.full_name.should == @valid_user.full_name
    entity.email.should == @valid_user.email
    entity.user_entity.should == true

    @valid_user.entity.entity_token.should == entity.entity_token
  end

  it "should have relationship" do
    should have_many(:stacks)
    should have_many(:transactions)
    should have_many(:entities)
  end

  it "should validate presence of" do
    should validate_presence_of :email
    should validate_presence_of :password
    should validate_presence_of :full_name
  end

  # it "should validate uniqueness of" do
  #   should validate_uniqueness_of :email
  #   should validate_uniqueness_of :username
  # end

  it "should validate uniqueness of username if is nil or blank" do
    @valid_user = FactoryGirl.create(:user, :username => 'test1')
    @another_valid_user = FactoryGirl.build(:user, :email => 'tim.j.gleeson@gmail.com', :username => 'test2')
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
end