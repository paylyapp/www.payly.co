class StacksController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def settings
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil? || @stack.archived == true
      render :error
    else
      render :settings
    end
  end

  def purchases
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil? ||  @stack.archived == true
      render :error
    else
      @transactions = @stack.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render :purchases
    end
  end

  def purchase
    @current_section = "purchases"
    @pre_title = "Pages"
    @user = current_user
    @transaction = current_user.transactions.find_by_transaction_token(params[:transaction_token])

    if @transaction.nil?
      render :error
    else
      render :purchase
    end
  end

  def new
    @current_section = "pages"
    @pre_title = "Pages"
    @stack = Stack.new
    @stack.seller_name = current_user.full_name
    @stack.seller_email = current_user.email

    @stack.page_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Stack.where(:page_token => random_token).exists?
    end

    render :new
  end

  def create
    @stack = current_user.stacks.build(params[:stack])

    if @stack.save
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :new
    end
  end

  def update
    params[:stack].delete(:primary_image) if  params[:stack][:primary_image].blank?
    params[:stack].delete(:digital_download_file) if params[:stack][:digital_download_file].blank?
    params[:stack][:digital_download_update_flag] = true unless params[:stack][:digital_download_file].blank?

    if params[:stack][:shipping_cost_value].nil? && params[:stack][:shipping_cost_term].nil?
      params[:stack][:shipping_cost_value] = []
      params[:stack][:shipping_cost_term] = []
    end

    if params[:stack][:custom_data_value].nil? && params[:stack][:custom_data_term].nil?
      params[:stack][:custom_data_value] = []
      params[:stack][:custom_data_term] = []
    elsif params[:stack][:custom_data_value].nil?
      params[:stack][:custom_data_value] = []
    end

    @stack = Stack.find_by_stack_token(params[:stack_token])

    if @stack.update_attributes(params[:stack])
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :settings
    end
  end

  def updated_download
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil? && @stack.archived == true
      render :error
    else
      if @stack.can_delivery_file?
        @stack.transactions.each { |transaction|
          TransactionMailer.updated(transaction).deliver
        }
        @stack.update_attributes(:digital_download_update_flag => false)
        redirect_to dashboard_stack_path(@stack.stack_token), :notice => "Emails have been sent."
      else
        redirect_to dashboard_stack_path(@stack.stack_token), :notice => "Emails could not be sent out."
      end
    end
  end

  def destroy
    @stack = Stack.find_by_stack_token(params[:stack_token])
    @stack.decommission

    redirect_to user_root_path
  end
end

