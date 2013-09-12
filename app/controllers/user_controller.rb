class UserController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def settings
    @current_section = 'settings'
    @user = User.find(current_user)
  end

  def dashboard
    @current_section = 'dashboard'
    @pre_title = "Dashboard"
    @user = current_user
  end

  def pages
    @current_section = 'pages'
    @pre_title = "Pages"
    @user = current_user
    @stacks = current_user.stacks
  end

  def purchases
    @current_section = 'purchases'
    @pre_title = "Purchases"
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
      @stacks = @user.stacks.where(:archived => false)
      @transactions = []
      @stacks.each do |stack|
        stack.transactions.each do |transaction|
          @transactions << transaction
        end
      end
      @transactions = @transactions.sort {|x,y| y["created_at"] <=> x["created_at"] }
      @transactions = @transactions.take(10)
    end
  end
end
