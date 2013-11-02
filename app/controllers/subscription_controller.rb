class SubscriptionController < ApplicationController
  include ActionView::Helpers::NumberHelper

  layout "subscriptions"

  def new
    @stack = Stack.find_by_page_token(params[:page_token])

    if @stack.nil? || @stack.throw_transaction_error?(current_user)
      render :error
    else
      if @stack.user.has_payment_provider?
        @subscription = @stack.subscriptions.new
        @subscription.transaction_amount = number_with_precision(@stack.charge_amount, :precision => 2) if @stack.charge_type == "fixed"

        @shipping_cost = @stack.shipping_cost_array

        render :new
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
      unless params[:subscription][:custom_data_value].blank?
        @custom_data_terms = []
        params[:subscription][:custom_data_value].each_index { |index|
          @custom_data_terms << stack.custom_data_term[index]
        }
        params[:subscription][:custom_data_term] = @custom_data_terms
      end

      if !params[:subscription][:shipping_cost].nil? && stack.require_shipping == true
        params[:subscription][:shipping_cost_term] = stack.shipping_cost_term[params[:subscription][:shipping_cost].to_i]
        params[:subscription][:shipping_cost_value] = stack.shipping_cost_value[params[:subscription][:shipping_cost].to_i]
      end

      @subscription = Subscription.new_by_stack(params, @stack)

      if @subscription.errors.none?
        if @subscription.save
          if @stack.webhook_url?
            stack.post_webhook_url(@subscription)
          end
          redirect_to complete_subscription_path
        else
          render :new
        end
      else
        render :new
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
end
