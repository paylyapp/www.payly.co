class Api::PagesController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # /api/pages.json
  def index
    @pages = current_user
    render :json => @pages
  end

  # /api/pages/s_abcdefg123456.json
  def show
    @page = current_user
    render :json => @page
  end

  private
  def get_auth_token
    if auth_token = params[:auth_token].blank?
      render :json => { :errors => ["Invalid authentication token."] },  :success => false, :status => :unauthorized
    end
  end
end
