class UserController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def root
    @pre_title = "Pages Dashboard"
    @user = current_user
    if @user.stacks.empty?
      @stack = Stack.new
      @stack.seller_name = @user.full_name
      @stack.seller_email = @user.email
    else
      @transactions = @user.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    end
  end

  def settings
    @user = User.find(current_user)
  end
end
