class Api::PUserController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
end