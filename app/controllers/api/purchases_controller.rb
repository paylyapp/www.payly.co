class Api::PurchasesController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  # /api/purchases/t_abcdefg123456.json
  def show
    @transaction = current_user.transactions.find_by_transaction_token(params[:token])
    @purchase = @transaction.api_array
    @json = {}
    @json[:status] = 'success'
    @json[:purchase] = @purchase
    render :json => @json
  end

  private
  def get_auth_token
    if auth_token = params[:auth_token].blank?
      render :json => { :errors => ["Invalid authentication token."] },  :success => false, :status => :unauthorized
    end
  end
end
