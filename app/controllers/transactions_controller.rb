class TransactionsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  layout "transactions"

  def stack_list

  end

  def new_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil? || @stack.archived
      render :error
    else
      if @stack.user.nil?
        render :error
      else
        if @stack.user.payment_method.blank?
          render :error
        else
          unless @stack.shipping_cost_term.blank?
            @shipping_cost = []
            @stack.shipping_cost_term.each_index { |index|
              cost = []

              cost << @stack.shipping_cost_term[index] + ' - $' + number_with_precision(@stack.shipping_cost_value[index], :precision => 2) + 'AUD'
              cost << index
              cost << {:"data-value" => number_with_precision(@stack.shipping_cost_value[index], :precision => 2)}
              @shipping_cost << cost
            }
          else
            @shipping_cost = false
          end
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
    end
  end

  def create_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?  || @stack.archived
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

        begin
          charge = Hay::Charges.create(@stack.user.pin_api_secret, payload)

          @transaction.charge_token = charge[:response][:token]

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
