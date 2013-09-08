class Api::PagesController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  # /api/pages.json
  def index
    @stacks = current_user.stacks.where({:archived => false})
    @pages = []
    @stacks.each do |stack|
      @pages << stack.api_array
    end
    @json = {}
    @json[:status] = 'success'
    @json[:pages] = @pages
    render :json => @json
  end

  # /api/pages/s_abcdefg123456.json
  def show
    @stack = current_user.stacks.find_by_stack_token(params[:token])
    @page = @stack.api_array
    @json = {}
    @json[:status] = 'success'
    @json[:page] = @page
    render :json => @json
  end

  private
  def get_auth_token
    if auth_token = params[:auth_token].blank?
      render :json => { :errors => ["Invalid authentication token."] },  :success => false, :status => :unauthorized
    end
  end
end
