require 'spec_helper'

describe DashboardController do
  let(:user){FactoryGirl.create :user}

  before do
    @user = user
  end

  describe "GET #index" do
    it "should go to login if user is not authenticated" do
      get :index
      expect(response).to redirect_to(new_user_session_path())
    end

    it "should go to the dashboard if user is authenticated" do
      sign_in @user
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
end
