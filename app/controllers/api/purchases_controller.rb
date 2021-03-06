class Api::PurchasesController < ApplicationController
  # This is our new function that comes before Devise's one
  before_filter :authenticate_user_from_token!
  prepend_before_filter :get_auth_token

  # /api/purchases/t_abcdefg12345
  def show
    @json = {}
    @transaction = current_user.transactions.find_by_transaction_token(params[:token])
    if @transaction.nil?
      @json[:status] = 'error'
      @json[:message] = 'The purchase could not be found.'
      render :json => @json, :success => false, :status => :not_found
    else
      @purchase = @transaction.api_array
      @json[:status] = 'success'
      @json[:purchase] = @purchase
      render :json => @json,  :success => true, :status => :ok
    end
  end

  protected
  def get_auth_token
    if auth_token = params[:auth_token].blank?
      @json[:status] = 'error'
      @json[:message] = 'Invalid authentication token.'
      render :json => @json, :success => false, :status => :unauthorized
    end
  end
end
