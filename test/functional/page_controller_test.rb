require 'test_helper'

class PageControllerTest < ActionController::TestCase
  test "should get stack" do
    get :stack
    assert_response :success
  end

end
