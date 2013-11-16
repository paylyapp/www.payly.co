class Entity::PurchasesController < ApplicationController
  layout "entity"
  before_filter :authenticate_user!


  def index
    @current_section = 'purchases'
    @pre_title = "Purchases"
    @user = current_user
    @transactions = @user.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
    render "index"
  end

  def show
    @current_section = "purchases"
    @pre_title = "Pages"
    @user = current_user
    @transaction = @user.transactions.find_by_transaction_token(params[:transaction_token])

    if @transaction.nil?
      render :error
    else
      render "show"
    end
  end
end