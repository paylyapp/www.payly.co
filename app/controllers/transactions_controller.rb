class TransactionsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  layout "transactions"

  def stack_list

  end

  def new_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil? || @stack.throw_transaction_error?(current_user)
      render :error
    else
      @shipping_cost = @stack.shipping_cost_array

      if @stack.user.payment_method == 'pin_payments' && (!@stack.user.pin_api_key.blank? && !@stack.user.pin_api_secret.blank?)
        @transaction = @stack.transactions.new
        @transaction.transaction_amount = number_with_precision(@stack.charge_amount, :precision => 2) if @stack.charge_type == "fixed"
        render :transaction
      elsif @stack.user.payment_method == 'braintree' && (!@stack.user.braintree_merchant_id.blank? && !@stack.user.braintree_api_key.blank? && !@stack.user.braintree_api_secret.blank? && !@stack.user.braintree_client_side_key.blank?)
        @transaction = @stack.transactions.new
        @transaction.transaction_amount = number_with_precision(@stack.charge_amount, :precision => 2) if @stack.charge_type == "fixed"
        render :transaction
      else
        render :error
      end
    end
  end

  def create_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil? || @stack.throw_transaction_error?(current_user)
      render :error
    else
      @shipping_cost = @stack.shipping_cost_array

      unless params[:transaction][:custom_data_value].blank?
        @custom_data_terms = []
        params[:transaction][:custom_data_value].each_index { |index|
          @custom_data_terms << @stack.custom_data_term[index]
        }
        params[:transaction][:custom_data_term] = @custom_data_terms
      end

      params[:transaction][:transaction_amount] = @stack.charge_amount if @stack.charge_type == "fixed"

      if !params[:transaction][:shipping_cost].nil? && @stack.require_shipping == true
        shipping_cost = @stack.shipping_cost_value[params[:transaction][:shipping_cost].to_i].to_f
        params[:transaction][:transaction_amount] = params[:transaction][:transaction_amount].to_f + shipping_cost
        params[:transaction][:shipping_cost_term] = @stack.shipping_cost_term[params[:transaction][:shipping_cost].to_i]
        params[:transaction][:shipping_cost_value] = @stack.shipping_cost_value[params[:transaction][:shipping_cost].to_i]
      end

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

        begin
          charge = Hay::Charges.create(@stack.user.pin_api_secret, payload)

          @transaction.charge_token = charge[:response][:token]

          @transaction.webhook_url

          if @transaction.save
            redirect_to page_complete_transaction_path
          else
            render :transaction
          end
        rescue Hay::InvalidRequestError
          flash[:status] = "We weren't able to process your credit card for some reason. Please try again."
          render :transaction
        end
      elsif @stack.user.payment_method == 'braintree'
        user_gateway = Braintree::Gateway.new(:merchant_id => @stack.user.braintree_merchant_id,
                                              :public_key => @stack.user.braintree_api_key,
                                              :private_key => @stack.user.braintree_api_secret,
                                              :environment => Rails.application.config.braintree_environment)

        charge = user_gateway.transaction.create(
          :type => 'sale',
          :amount => params[:transaction][:transaction_amount],
          :credit_card => {
            :cardholder_name => params[:name],
            :number => params[:number],
            :cvv => params[:cvv],
            :expiration_month => params[:month],
            :expiration_year => params[:year]
          },
          :billing => {
            :street_address => params[:address_line1],
            :extended_address => params[:address_line2],
            :locality => params[:city],
            :region => params[:state],
            :postal_code => params[:postcode],
            :country_name => params[:address_country][:country]
          },
          :options => {
            :submit_for_settlement => true
          }
        )

        if charge.success?
          @transaction.charge_token = charge.transaction.id

          if @transaction.save
            redirect_to page_complete_transaction_path
          else
            render :transaction
          end
        elsif !charge.errors.nil?
          flash[:status] = charge.errors
          render :transaction
        elsif charge.transaction.status == 'processor_declined'
          flash[:status] = "(#{charge.transaction.processor_response_code}) #{charge.transaction.processor_response_text}"
          render :transaction
        elsif charge.transaction.status == 'gateway_rejected'
          flash[:status] = "(#{charge.transaction.gateway_rejection_code}) #{charge.transaction.gateway_rejection_reason}"
          render :transaction
        else
          flash[:status] = "Something went wrong. Please try again."
          render :transaction
        end
      end
    end
  end

  def complete_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?  || @stack.archived
      render :error
    else
      render :complete_transaction
    end
  end

  def download
    transaction = Transaction.find_by_transaction_token(params[:token])

    if transaction.nil?
      render "page/error"
    else
      # fix logic here
      if transaction.stack.has_digital_download
        redirect_to transaction.stack.digital_download_file.expiring_url(600)
      else
        render "page/error"
      end
    end
  end
end
