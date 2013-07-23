class DashboardController < ApplicationController
  layout "dashboard"
  before_filter :authenticate_user!

  def index
    @user = current_user
    @stack = Stack.new
    @stack.seller_name = @user.full_name
    @stack.seller_email = @user.email
    @transactions = @user.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
  end

  def stack
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :stack_error
    else
      render :stack
    end
  end

  def stack_transactions
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :stack_error
    else
      @transactions = @stack.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render :stack_transactions
    end
  end

  def stack_transaction
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :stack_error
    else
      @transaction = @stack.transactions.find_by_transaction_token(params[:transaction_token])
      if @transaction.nil?
        render :stack_error
      else
        render :stack_transaction
      end
    end
  end

  def stack_updated_download
    @user = current_user
    @stack = current_user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :stack_error
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

  def new_stack
    @stack = Stack.new
    @stack.seller_name = current_user.full_name
    @stack.seller_email = current_user.email

    render :new_stack
  end

  def create_stack
    @stack = current_user.stacks.build(params[:stack])

    if @stack.save
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :new_stack
    end
  end

  def update_stack
    params[:stack].delete(:primary_image) if  params[:stack][:primary_image].blank?
    params[:stack].delete(:digital_download_file) if params[:stack][:digital_download_file].blank?
    params[:stack][:digital_download_update_flag] = true unless params[:stack][:digital_download_file].blank?

    @stack = Stack.find_by_stack_token(params[:stack_token])

    if @stack.update_attributes(params[:stack])
      redirect_to dashboard_stack_path(@stack.stack_token)
    else
      render :stack
    end
  end

  def destroy_stack
    @stack = Stack.find_by_stack_token(params[:stack_token])
    @stack.destroy

    redirect_to user_root_path
  end
end
