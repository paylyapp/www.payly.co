class CustomerController < ApplicationController
  layout "pocket"

  def index
    if session[:pocket_token].nil? || Customer.find_by_session_token(session[:pocket_token]).nil?
      token = params[:token]
      if token
        @customer = Customer.find_by_user_token(token)
        if @customer.nil?
          render "form"
        else
          session[:pocket_token] = @customer.session_token # generate base64 key
          redirect_to pocket_transactions_path
        end
      else
        @customer = Customer.new
        render "form"
      end
    else
      redirect_to pocket_transactions_path
    end
  end

  def list
    if session[:pocket_token].nil? || Customer.find_by_session_token(session[:pocket_token]).nil?
      redirect_to pocket_path
    else
      @customer = Customer.find_by_session_token(session[:pocket_token])
      @transactions = @customer.transactions.paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
      render "list"
    end
  end

  def transaction
    @customer = Customer.find_by_session_token(session[:pocket_token])

    if @customer.nil?
      redirect_to pocket_path
    else
      @transaction = @customer.transactions.find_by_transaction_token(params[:transaction_token])

      if @transaction.nil?
        redirect_to pocket_transactions_path
      else
        render "transaction"
      end
    end
  end

  def create
    @customer = Customer.where(:email => params[:customer][:email]).first_or_create
    CustomerMailer.confirmation(@customer).deliver
  end
end
