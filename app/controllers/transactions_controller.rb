class TransactionsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  layout "transactions"

  def new
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil? || @stack.throw_transaction_error?(current_user)
      render :error
    else
      if @stack.user.has_payment_provider?
        @transaction = @stack.transactions.new

        @params = params
        @params.delete("controller")
        @params.delete("action")
        @params.delete("page_token")

        @name = @params[:name]
        if @name
          @transaction.buyer_name = @name
        end
        @params.delete("name")

        @email = @params[:email]
        if @email
          @transaction.buyer_email = @email
        end
        @params.delete("email")

        @price = @params[:price]
        if @price && @stack.charge_type == 'any'
          @transaction.transaction_amount = number_with_precision(@price, :precision => 2)
        elsif @stack.charge_type == 'fixed'
          @transaction.transaction_amount = number_with_precision(@stack.charge_amount, :precision => 2)
        end
        @params.delete("price")

        @stack.custom_data_term.each_index { |index|
          encoded_term = @stack.custom_data_term[index].downcase.gsub(' ', '-')
          if @params.has_key?(encoded_term)
            @transaction.custom_data_value[index] = @params[encoded_term]
          end
        }

        @shipping_cost = @stack.shipping_cost_array

        render :transaction
        impressionist(@stack)
      else
        render :error
      end
    end
  end

  def create
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

      @transaction = Transaction.new_by_stack(params, @stack)

      if @transaction.errors.none?
        if @transaction.save
          if @stack.webhook_url?
            stack.post_webhook_url(@transaction)
          end
          redirect_to page_complete_transaction_path
        else
          render :transaction
        end
      else
        render :transaction
      end
    end
  end

  def complete
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?
      render :error
    else
      render :complete
    end
  end

  def download
    transaction = Transaction.find_by_transaction_token(params[:token])

    if transaction.nil? && transaction.stack_digital_download_file.exists?
      render :error
    else
      render :download
    end
  end
end
