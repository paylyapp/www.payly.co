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
    @transactions = @user.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    render :purchases
  end

  def subscriptions
    @current_section = 'subscriptions'
    @pre_title = "Purchases"
    @user = current_user
    @subscriptions = @user.subscriptions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    render :subscriptions
  end
end
