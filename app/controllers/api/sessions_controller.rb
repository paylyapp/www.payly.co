class Api::SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # /api/sessions/create
  def create
    resource = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      resource.ensure_authentication_token!
      @json = {}
      @json[:status] = 'success'
      @json[:user] = {}
      @json[:user][:id] = resource.id
      @json[:user][:authentication_token] = resource.authentication_token
      render :json => @json,  :success => true, :status => :created
    else
      return invalid_login_attempt
    end
  end

  # /api/sessions/destroy
  def destroy
      @user=User.where(:authentication_token=>params[:auth_token]).first
      @user.reset_authentication_token! unless @user.nil?
      @json[:user] = {}
      @json[:status] = 'success'
      @json[:message] = 'Session deleted.'
      render :json => @json,  :success => true, :status => :ok
  end

  def invalid_login_attempt
      warden.custom_failure!
      @json[:user] = {}
      @json[:status] = 'success'
      @json[:message] = 'Invalid email or password.'
      render :json => @json, :success => false, :status => :unauthorized
  end
end
