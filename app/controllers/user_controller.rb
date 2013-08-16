class UserController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def root
    @pre_title = "Pages Dashboard"
    @user = current_user
    if @user.stacks.where(:archived => false).empty?
      @stack = Stack.new
      @stack.seller_name = @user.full_name
      @stack.seller_email = @user.email
      @stack.page_token = loop do
        random_token = SecureRandom.urlsafe_base64
        break random_token unless Stack.where(:page_token => random_token).exists?
      end
    else
      @transactions = @user.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    end
  end

  def settings
    @user = User.find(current_user)
  end
end
