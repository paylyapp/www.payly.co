class Api::SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # /api/sessions/create
  def create
    resource = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:password])
      resource.ensure_authentication_token!
      render :json => { :authentication_token => resource.authentication_token, :user_id => resource.id }, :status => :created
    else
      return invalid_login_attempt
    end
  end

  # /api/sessions/destroy
  def destroy
      @user=User.where(:authentication_token=>params[:auth_token]).first
      @user.reset_authentication_token! unless @user.nil?
      render :json => { :message => ["Session deleted."] },  :success => true, :status => :ok
  end

  def invalid_login_attempt
      warden.custom_failure!
      render :json => { :errors => ["Invalid email or password."] },  :success => false, :status => :unauthorized
  end
end
