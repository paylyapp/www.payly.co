class PageController < ApplicationController
  layout "transactions"

  def new_transaction
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil?
      render :error
    else
      if @stack.user.nil?
        render :error
      else 
        if @stack.user.pin_api_key.blank? || @stack.user.pin_api_secret.blank?
          render :error
        else
          @transaction = @stack.transactions.new
          render :transaction
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

      if @transaction.save
        redirect_to page_complete_transaction_path
      else
        render :transaction
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