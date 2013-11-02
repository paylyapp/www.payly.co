require 'spec_helper'

describe SubscriptionController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'complete'" do
    it "returns http success" do
      get 'complete'
      response.should be_success
    end
  end

end
