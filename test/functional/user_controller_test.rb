require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get settings" do
    get :settings
    assert_response :success
  end

end
