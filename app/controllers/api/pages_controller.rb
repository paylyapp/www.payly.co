class Api::PagesController < ApplicationController
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  # /api/pages
  def index
    @stacks = current_user.stacks.where({:archived => false})
    @pages = []
    @stacks.each do |stack|
      @pages << stack.api_array
    end
    @json = {}
    @json[:status] = 'success'
    @json[:pages] = @pages
    render :json => @json,  :success => true, :status => :ok
  end

  # /api/pages/s_abcdefg123456
  def show
    @json = {}
    @stack = current_user.stacks.find_by_stack_token(params[:token])
    if @stack.nil?
      @json[:status] = 'error'
      @json[:message] = 'The page could not be found.'
      render :json => @json, :success => false, :status => :not_found
    else
      @page = @stack.api_array
      @json[:status] = 'success'
      @json[:page] = @page
      render :json => @json,  :success => true, :status => :ok
    end
  end

  private
  def get_auth_token
    if auth_token = params[:auth_token].blank?
      @json[:status] = 'error'
      @json[:message] = 'Invalid authentication token.'
      render :json => @json, :success => false, :status => :unauthorized
    end
  end
end
