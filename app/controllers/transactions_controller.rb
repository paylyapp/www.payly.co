class TransactionsController < ApplicationController
  layout "transactions"

  def new_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?
      render :error
    else
      if @stack.user.nil?
        render :error
      else
        if @stack.user.payment_method.blank?

        else
          if @stack.user.payment_method == 'pin_payments' && (!@stack.user.pin_api_key.blank? && !@stack.user.pin_api_secret.blank?)
            @transaction = @stack.transactions.new
            render :transaction
          elsif @stack.user.payment_method == 'braintree' && (!@stack.user.braintree_merchant_id.blank? && !@stack.user.braintree_api_key.blank? && !@stack.user.braintree_api_secret.blank? && !@stack.user.braintree_client_side_key.blank?)
            @transaction = @stack.transactions.new
            render :transaction
          else
            render :error
          end
        end
      end
    end
  end

  def create_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?
      render :error
    else
      params[:transaction][:transaction_amount] = @stack.charge_amount if @stack.charge_type == "fixed"

      @transaction = @stack.transactions.build(params[:transaction])

      if @stack.user.payment_method == 'pin_payments'
        amount = (params[:transaction][:transaction_amount] * 100).to_i

        payload = {
          'email' => params[:transaction][:buyer_email],
          'description' => @stack.product_name,
          'amount' => amount,
          'currency' => @stack.charge_currency,
          'ip_address' => params[:transaction][:buyer_ip_address],
          'card_token' => params[:transaction][:card_token]
        }

        charge = Hay::Charges.create(@stack.user.pin_api_secret, payload)

        # do error messaging here!
        @transaction.charge_token = charge[:response][:token]

        if @transaction.save
          redirect_to page_complete_transaction_path
        else
          render :transaction
        end
      elsif @stack.user.payment_method == 'braintree'
        user_gateway = Braintree::Gateway.new(:merchant_id => @stack.user.braintree_merchant_id, :public_key => @stack.user.braintree_api_key, :private_key => @stack.user.braintree_api_secret, :environment => :sandbox)

        charge = user_gateway.transaction.create(
          :type => 'sale',
          :amount => params[:transaction][:transaction_amount],
          :credit_card => {
            :number => params[:number],
            :cvv => params[:cvv],
            :expiration_month => params[:month],
            :expiration_year => params[:year]
          },
          :options => {
            :submit_for_settlement => true
          }
        )

        # do error messaging here!
        @transaction.charge_token = charge.transaction.id

        if @transaction.save
          redirect_to page_complete_transaction_path
        else
          render :transaction
        end
      end
    end
  end

  def complete_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?
      render :error
    else
      render :complete_transaction
    end
  end
end
