class CustomerController < ApplicationController
  layout "pocket"

  def index
    @pre_title = 'Pocket'
    if session[:pocket_token].nil? || Customer.find_by_session_token(session[:pocket_token]).nil?
      token = params[:token]
      if token
        @customer = Customer.find_by_user_token(token)
        if @customer.nil?
          render :form
        else
          session[:pocket_token] = @customer.session_token # generate base64 key
          redirect_to pocket_transactions_path
        end
      else
        @customer = Customer.new
        render :form
      end
    else
      redirect_to pocket_transactions_path
    end
  end

  def list
    @pre_title = 'Your Pocket'
    if session[:pocket_token].nil? || Customer.find_by_session_token(session[:pocket_token]).nil?
      redirect_to pocket_path
    else
      @customer = Customer.find_by_session_token(session[:pocket_token])
      @subscriptions = @customer.subscriptions.unscoped.paginate(:page => params[:subscriptions_page], :per_page => 5).order('created_at DESC')
      @transactions = @customer.transactions.unscoped.paginate(:page => params[:transactions_page], :per_page => 5).order('created_at DESC')
      render :list
    end
  end

  def show
    @pre_title = 'Your Pocket'
    @customer = Customer.find_by_session_token(session[:pocket_token])

    if @customer.nil?
      redirect_to pocket_path
    else
      @transaction = @customer.transactions.find_by_transaction_token(params[:transaction_token])

      if @transaction.nil?
        redirect_to pocket_transactions_path
      else
        @stack = @transaction.stack
        render :show
      end
    end
  end

  def create
    @pre_title = 'Pocket'
    @customer = Customer.where(:email => params[:customer][:email]).first_or_create
    CustomerMailer.confirmation(@customer).deliver
  end

  def subscription
    @pre_title = 'Your Pocket'
    if session[:pocket_token].nil? || Customer.find_by_session_token(session[:pocket_token]).nil?
      redirect_to pocket_path
    else
      @customer = Customer.find_by_session_token(session[:pocket_token])
      @subscription = @customer.subscriptions.unscoped.find_by_subscription_token(params[:subscription_token])

      if @subscription.nil?
        redirect_to pocket_transactions_path
      else
        @stack = @subscription.stack
        @transactions = @subscription.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
        render :subscription
      end
    end
  end

  def subscription_edit
    @pre_title = 'Your Pocket'
    if session[:pocket_token].nil? || Customer.find_by_session_token(session[:pocket_token]).nil?
      redirect_to pocket_path
    else
      @customer = Customer.find_by_session_token(session[:pocket_token])
      @subscription = @customer.subscriptions.find_by_subscription_token(params[:subscription_token])


      if @subscription.nil?
        redirect_to pocket_transactions_path
      else
        @stack = @subscription.stack
        @shipping_cost = @stack.shipping_cost_array
      end
    end
  end

  def subscription_update
    @subscription = Subscription.find_by_subscription_token(params[:subscription_token])
    @subscription.update_customer_information(params[:subscription])

    if @subscription.errors.none?
      @subscription.update_attributes(params[:subscription])
      redirect_to pocket_subscription_url(@subscription.subscription_token)
    else
      render :subscription_edit
    end
  end

  def subscription_destroy
    @customer = Customer.find_by_session_token(session[:pocket_token])
    @subscription = @customer.subscriptions.find_by_subscription_token(params[:subscription_token])

    @subscription.decommission()

    redirect_to pocket_transactions_path
  end
end
