class UserController < ApplicationController
  layout "dashboard"
  before_filter :authenticate_user!

  def settings
    @user = User.find(current_user)
  end
end
