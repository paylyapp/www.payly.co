class Subscription < ActiveRecord::Base
  attr_accessible :subscription_token, :stack_token, :transaction_amount,
                  :buyer_email, :buyer_name, :buyer_ip_address,
                  :customer_token, :card_token,
                  :billing_address_line1, :billing_address_line2,
                  :billing_address_city, :billing_address_postcode, :billing_address_state,
                  :billing_address_country,
                  :shipping_cost, :shipping_cost_term, :shipping_cost_value,
                  :shipping_full_name, :shipping_address_line1, :shipping_address_line2,
                  :shipping_address_city, :shipping_address_postcode, :shipping_address_state,
                  :shipping_address_country,
                  :custom_data_term, :custom_data_value,
                  :status

  belongs_to :stack, :foreign_key => :stack_token
  belongs_to :customer
  has_many :transactions, :foreign_key => :subscription_token, :primary_key => :subscription_token
  has_many :failed_transaction, :foreign_key => :subscription_token, :primary_key => :subscription_token

  default_scope { where status: true }

  after_create :send_subscription_emails

  def self.new_by_stack(params, stack)
    subscription = self.new(params[:subscription])
    subscription.stack_token = stack.id

    subscription.generate_token

    if stack.user.payment_provider_is_pin_payments?
      begin
        customer_payload = {
          'email'=>subscription[:buyer_email],
          'card_token' => subscription[:card_token]
        }

        customer = Hay::Customers.create(stack.user.pin_api_secret, customer_payload)

        subscription.customer_token = customer[:response][:token]
      rescue Hay::APIConnectionError => e
        subscription.errors.add :base, e.message
      rescue Hay::InvalidRequestError => e
        subscription.errors.add :base, e.message
      rescue Hay::AuthenticationError => e
        subscription.errors.add :base, e.message
      rescue Hay::APIError => e
        subscription.errors.add :base, e.message
      end
    elsif stack.user.payment_provider_is_stripe?
      Stripe.api_key = stack.user.stripe_api_secret

      customer = Stripe::Customer.create(
        :description => "Customer for https://payly.co",
        :card => subscription[:card_token]
      )

      subscription.customer_token = customer[:id]
    elsif stack.user.payment_provider_is_braintree?
    end

    if subscription.errors.none?
      transaction = subscription.create_transaction

      if transaction.errors.none?
        if transaction.save
          if transaction.stack.webhook_url?
            subscription.stack.post_webhook_url(transaction)
          end
        end
      else
        subscription.errors.add :base, transaction.errors
      end
    end

    subscription
  end

  def self.monthly_transactions
    subscriptions = Subscription.all

    subscriptions.each do |subscription|
      subscription.new_transaction()
    end
  end

  def update_customer_information(params)
    if stack.user.payment_provider_is_pin_payments?
      begin
        payload = {}
        payload[:card_token] = params[:card_token]
        customer = Hay::Customers.show(self.stack.user.pin_api_secret, self.customer_token)
        Hay::Customers.update(self.stack.user.pin_api_secret, customer[:response][:token], payload)
      rescue Hay::APIConnectionError => e
        self.errors.add :base, e.message
      rescue Hay::InvalidRequestError => e
        self.errors.add :base, e.message
      rescue Hay::AuthenticationError => e
        self.errors.add :base, e.message
      rescue Hay::APIError => e
        self.errors.add :base, e.message
      end
    elsif stack.user.payment_provider_is_stripe?
      begin
        Stripe.api_key = stack.user.stripe_api_secret
        cu = Stripe::Customer.retrieve(self.customer_token)
        cu.card = params[:card_token]
        cu.save
      rescue Stripe::CardError => e
        self.errors.add :base, e.message
      rescue Stripe::StripeError => e
        self.errors.add :base, e.message
      end
    elsif stack.user.payment_provider_is_braintree?
    end
    self
  end

  def new_transaction
    subscription = self
    transaction = subscription.create_transaction

    if transaction.errors.none?
      if transaction.save
        if transaction.stack.webhook_url?
          subscription.stack.post_webhook_url(transaction)
        end
      end
    else
      params = {}
      params[:reason] = transaction.errors.messages[:base][0]
      params[:subscription_token] = subscription.subscription_token

      failed_transaction = FailedTransaction.new(params)
      failed_transaction.save!

      self.send_failed_transaction_emails(failed_transaction)
    end
  end

  def create_transaction
    stack = Stack.find(self.stack_token)

    params = {}
    params[:transaction] = {}
    params[:transaction][:subscription_token] = self.subscription_token
    params[:transaction][:buyer_name] = self.buyer_name
    params[:transaction][:buyer_email] = self.buyer_email
    params[:transaction][:buyer_ip_address] = self.buyer_ip_address
    params[:transaction][:transaction_amount] = self.transaction_amount
    params[:transaction][:billing_address_line1] = self.billing_address_line1
    params[:transaction][:billing_address_line2] = self.billing_address_line2
    params[:transaction][:billing_address_city] = self.billing_address_city
    params[:transaction][:billing_address_state] = self.billing_address_state
    params[:transaction][:billing_address_country] = self.billing_address_country
    params[:transaction][:billing_address_postcode] = self.billing_address_postcode
    params[:transaction][:shipping_address_line1] = self.shipping_address_line1
    params[:transaction][:shipping_address_line2] = self.shipping_address_line2
    params[:transaction][:shipping_address_city] = self.shipping_address_city
    params[:transaction][:shipping_address_state] = self.shipping_address_state
    params[:transaction][:shipping_address_country] = self.shipping_address_country
    params[:transaction][:shipping_address_postcode] = self.shipping_address_postcode
    params[:transaction][:shipping_cost] = self.shipping_cost
    params[:transaction][:shipping_cost_term] = self.shipping_cost_term
    params[:transaction][:shipping_cost_value] = self.shipping_cost_value
    params[:transaction][:custom_data_term] = self.custom_data_term
    params[:transaction][:custom_data_value] = self.custom_data_value

    if stack.user.payment_provider_is_pin_payments?
      customer = Hay::Customers.show(stack.user.pin_api_secret, self.customer_token)
      params[:transaction][:card_token] = customer[:response][:card][:token]
    elsif stack.user.payment_provider_is_stripe?
      Stripe.api_key = stack.user.stripe_api_secret
      customer = Stripe::Customer.retrieve(self.customer_token)
      params[:transaction][:customer_token] = self.customer_token
      params[:transaction][:card_token] = customer[:default_card]
    elsif stack.user.payment_provider_is_braintree?
    end

    transaction = Transaction.new_by_stack(params, self.stack)

    transaction
  end

  def decommission
    self.status = false
    self.customer_token = nil
    self.card_token = nil
    self.save!

    SubscriptionMailer.destroy_subscription(self).deliver
  end

  def generate_token
    random_token = 's_'

    self.subscription_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless Subscription.where(:subscription_token => random_token).exists?
    end
  end

  def send_subscription_emails
    SubscriptionMailer.new_subscription(self).deliver
  end

  def send_failed_transaction_emails(failed_transaction)
    SubscriptionMailer.seller_failed_transaction(self).deliver
    SubscriptionMailer.buyer_failed_transaction(self).deliver
  end
end
