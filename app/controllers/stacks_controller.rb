class StacksController < ApplicationController
  layout "user"
  before_filter :authenticate_user!

  def new
    @current_section = "pages"
    @pre_title = "Pages"
  end

  def new_one_time
    @current_section = "pages"
    @pre_title = "Pages"
    @stack = Stack.new
  end

  def new_digital_download
    @current_section = "pages"
    @pre_title = "Pages"
    @stack = Stack.new
  end

  def new_subscription
    @current_section = "pages"
    @pre_title = "Pages"
    @stack = Stack.new
  end

  def create_one_time
    @stack = Stack.new_one_time_by_user(params[:stack], current_user)

    if @stack.save
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :new
    end
  end

  def create_digital_download
    @stack = Stack.new_digital_download_by_user(params[:stack], current_user)

    if @stack.save
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :new
    end
  end

  def create_subscription
    @stack = Stack.new_subscription_by_user(params[:stack], current_user)

    if @stack.save
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :new
    end
  end

  # GET /pages/:token
  def settings
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = @user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :error
    else
      render :settings
    end
  end

  # PUT /pages/:token
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

  # GET /pages/:token/purchases
  def purchases
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = @user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :error
    else
      @transactions = @stack.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render :purchases
    end
  end

  # GET /purchases/:token
  def purchase
    @current_section = "purchases"
    @pre_title = "Pages"
    @user = current_user
    @transaction = @user.transactions.find_by_transaction_token(params[:transaction_token])

    if @transaction.nil?
      render :error
    else
      render :purchase
    end
  end

  # GET /pages/:token/subscriptions
  def subscriptions
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = @user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :error
    else
      @subscriptions = @stack.subscriptions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render :subscriptions
    end
  end

  # GET /subscriptions/:token
  def subscription
    @current_section = "subscriptions"
    @pre_title = "Pages"
    @user = current_user
    @subscription = @user.subscriptions.find_by_subscription_token(params[:subscription_token])

    if @subscription.nil?
      render :error
    else
      @transactions = @subscription.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render :subscription
    end
  end

  # DELETE /subscription/:token
  def subscription_destroy
    @user = current_user
    @subscription = @user.subscriptions.find_by_subscription_token(params[:subscription_token])

    @subscription.decommision()

    redirect_to user_subscriptions_path
  end
end