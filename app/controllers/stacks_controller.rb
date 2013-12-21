class StacksController < ApplicationController
  include CsvHelper
  layout "user"
  before_filter :authenticate_user!

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

  def purchases
    @current_section = "pages"
    @pre_title = "Pages"
    @user = current_user
    @stack = @user.stacks.find_by_stack_token(params[:stack_token])

    if @stack.nil?
      render :error
    else
      @transactions = @stack.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      respond_to do |format|
        format.html { render :purchases }
        format.csv { render :layout => false }
      end
    end
  end

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

  def new
    @current_section = "pages"
    @pre_title = "Pages"
  end

  def one_time
    @current_section = "pages"
    @pre_title = "Pages"
    @stack = Stack.new
  end

  def digital_download
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

        @stack.transactions.each { |transaction|
          TransactionMailer.updated(transaction).deliver
        }
        @stack.update_attributes(:digital_download_update_flag => false)
        redirect_to dashboard_stack_path(@stack.stack_token), :notice => "Emails have been sent."

    end
  end

  def destroy
    @stack = Stack.find_by_stack_token(params[:stack_token])
    @stack.decommission

    redirect_to user_root_path
  end
end

