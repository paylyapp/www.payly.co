class UserController < ApplicationController
  layout "dashboard"
  before_filter :authenticate_user!

  def settings
    @user = User.select([:full_name, :email, :encrypted_pin_api_key, :encrypted_pin_api_secret]).find(current_user)
  end
end
