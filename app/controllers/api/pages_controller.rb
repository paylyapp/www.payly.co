class Api::PagesController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  # /api/pages.json
  def index
    @pages = current_user.stacks
    render :json => @pages
  end

  # /api/pages/s_abcdefg123456.json
  def show
    @page = current_user.stacks.find_by_stack_token(params[:token])
    render :json => @page
  end

  private
  def get_auth_token
    if auth_token = params[:auth_token].blank?
      render :json => { :errors => ["Invalid authentication token."] },  :success => false, :status => :unauthorized
    end
  end
end
