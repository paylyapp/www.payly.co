class DashboardController < ApplicationController
  layout "dashboard"
  before_filter :authenticate_user!

  def index
    @pre_title = "Pages Dashboard"
    @user = current_user
    @stack = Stack.new
    @stack.seller_name = @user.full_name
    @stack.seller_email = @user.email
    @transactions = @user.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
  end

end
