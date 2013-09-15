class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource
  before_filter :authenticate

  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    end
  end

  def authenticate
    if Rails.env == 'staging'
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['USERNAME'] && password == ENV['PASSWORD']
      end
    end
  end

  private

  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_token!
    user_token = params[:user_token].presence
    user       = user_token && User.find_by_authentication_token(user_token)

    if user
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in user, store: false
    end
  end
end
