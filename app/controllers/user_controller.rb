class UserController < ApplicationController
  include CsvHelper

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
    respond_to do |format|
      format.html { render :purchases }
      format.csv { render :layout => false }
    end
  end
end
