require 'test_helper'

class StacksControllerTest < ActionController::TestCase
  setup do
    @stack = stacks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stack" do
    assert_difference('Stack.count') do
      post :create, stack: { bcc_receipt: @stack.bcc_receipt, charge_amount: @stack.charge_amount, charge_type: @stack.charge_type, description: @stack.description, ga_id: @stack.ga_id, product_name: @stack.product_name, require_billing: @stack.require_billing, require_shipping: @stack.require_shipping, return_url: @stack.return_url, seller_email: @stack.seller_email, seller_name: @stack.seller_name, send_invoice_email: @stack.send_invoice_email }
    end

    assert_redirected_to stack_path(assigns(:stack))
  end

  test "should show stack" do
    get :show, id: @stack
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stack
    assert_response :success
  end

  test "should update stack" do
    put :update, id: @stack, stack: { bcc_receipt: @stack.bcc_receipt, charge_amount: @stack.charge_amount, charge_type: @stack.charge_type, description: @stack.description, ga_id: @stack.ga_id, product_name: @stack.product_name, require_billing: @stack.require_billing, require_shipping: @stack.require_shipping, return_url: @stack.return_url, seller_email: @stack.seller_email, seller_name: @stack.seller_name, send_invoice_email: @stack.send_invoice_email }
    assert_redirected_to stack_path(assigns(:stack))
  end

  test "should destroy stack" do
    assert_difference('Stack.count', -1) do
      delete :destroy, id: @stack
    end

    assert_redirected_to stacks_path
  end
end
