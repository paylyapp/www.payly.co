class Api::SubscriptionsController < ApplicationController
  # This is our new function that comes before Devise's one
  before_filter :authenticate_user_from_token!
  prepend_before_filter :get_auth_token

  # /api/subscriptions/s_abcdefg12345
  def index

  end

  # /api/subscriptions/s_abcdefg12345
  def show
    @json = {}
    @subscription = current_user.subscriptions.find_by_subscription_token(params[:token])
    if @subscription.nil?
      @json[:status] = 'error'
      @json[:message] = 'The purchase could not be found.'
      render :json => @json, :success => false, :status => :not_found
    else
      @subscription = @subscription.api_array
      @json[:status] = 'success'
      @json[:subscription] = @subscription
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
