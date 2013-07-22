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
end
