require 'spec_helper'

describe Entity do
  it "has a valid factory" do
    @valid_entity = FactoryGirl.create(:entity)
    @valid_entity.should be_valid
  end
end
