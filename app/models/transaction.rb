class Transaction < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  attr_accessible :stack_token,
                  :transaction_token, :transaction_amount,
                  :buyer_email, :buyer_name, :buyer_ip_address,
                  :charge_token, :card_token,
                  :billing_address_line1, :billing_address_line2,
                  :billing_address_city, :billing_address_postcode, :billing_address_state,
                  :billing_address_country,
                  :base_cost,
                  :shipping_cost, :shipping_cost_term, :shipping_cost_value,
                  :surcharge_cost,
                  :shipping_full_name, :shipping_address_line1, :shipping_address_line2,
                  :shipping_address_city, :shipping_address_postcode, :shipping_address_state,
                  :shipping_address_country,
                  :custom_data_term, :custom_data_value

  belongs_to :stack, :foreign_key => :stack_token
  belongs_to :customer

  delegate :stack_token, :product_name, :charge_currency, :require_shipping,
           :seller_email, :seller_trading_name, :seller_abn, :bcc_receipt, :analytics_key,
           :has_digital_download, :digital_download_file, :primary_image,
           :description,
           :to => :stack, :prefix => true

  validates :buyer_name, :presence => true
  validates :buyer_email, :presence => true
  validates :transaction_amount, :presence => true

  before_create :generate_token
  after_create :send_transaction_emails

  def api_array
    purchase = {}
    purchase[:id] = self.transaction_token
    purchase[:page_id] = self.stack.stack_token
    purchase[:buyer] = {}
      purchase[:buyer][:name] = self.buyer_name
      purchase[:buyer][:email] = self.buyer_email
    purchase[:price] = number_to_currency(self.transaction_amount, :precision => 2)
    purchase[:shipping] = {}
      purchase[:shipping][:type] = self.shipping_cost_term
      purchase[:shipping][:price] = number_to_currency(self.shipping_cost, :precision => 2)
      purchase[:shipping][:address_line1] = self.shipping_address_line1
      purchase[:shipping][:address_line2] = self.shipping_address_line2
      purchase[:shipping][:address_city] = self.shipping_address_city
      purchase[:shipping][:address_postcode] = self.shipping_address_postcode
      purchase[:shipping][:address_state] = self.shipping_address_state
      purchase[:shipping][:address_country] = self.shipping_address_country
    purchase[:custom_fields] = []
    unless self.custom_data_term.blank?
      self.custom_data_term.each_index do |index|
        custom_field = {}
        custom_field[:label] = self.custom_data_term[index]
        custom_field[:value] = self.custom_data_value[index]
        purchase[:custom_fields] << custom_field
      end
    end
    purchase
  end

  def self.new_by_stack(params, stack)
    transaction = self.new(params[:transaction])
    transaction.stack_token = stack.id

    amount = transaction[:transaction_amount].to_f
    transaction.base_cost = amount

    if stack.has_shipping? && !transaction.shipping_cost.nil?
      transaction_shipping_cost = transaction.shipping_cost.to_i

      transaction.shipping_cost_term = stack.shipping_cost_term[transaction_shipping_cost]
      transaction.shipping_cost_value = stack.shipping_cost_value[transaction_shipping_cost].to_f

      amount = amount + transaction.shipping_cost_value
      transaction.transaction_amount = amount
    end

    if stack.has_surcharge?
      unit = stack.surcharge_unit
      value = stack.surcharge_value
      if unit == 'percentage'
        value = value / 100 + 1
        amount = amount * value
        transaction.surcharge_cost = amount - transaction[:transaction_amount]
        transaction.transaction_amount = amount
      end
      if unit == 'dollar'
        amount = amount + value
        transaction.surcharge_cost = value
        transaction.transaction_amount = amount
      end
    end

    if stack.user.payment_provider_is_pin_payments?
      amount = (amount * 100).to_i

      payload = {
        'email' => transaction[:buyer_email],
        'description' => stack.product_name,
        'amount' => amount,
        'currency' => stack.charge_currency,
        'ip_address' => transaction[:buyer_ip_address],
        'card_token' => transaction[:card_token]
      }

      begin
        charge = Hay::Charges.create(stack.user.pin_api_secret, payload)
        transaction.charge_token = charge[:response][:token]
      rescue Hay::APIConnectionError => e
        transaction.errors.add :base, e.message
      rescue Hay::InvalidRequestError => e
        transaction.errors.add :base, e.message
      rescue Hay::AuthenticationError => e
        transaction.errors.add :base, e.message
      rescue Hay::APIError => e
        transaction.errors.add :base, e.message
      end

    elsif stack.user.payment_provider_is_stripe?
      Stripe.api_key = stack.user.stripe_api_secret
      amount = (amount * 100).to_i

      begin
        charge = Stripe::Charge.create(
          :amount => amount,
          :currency => stack.charge_currency,
          :card => transaction[:card_token],
          :description => stack.product_name
        )
        transaction.charge_token = charge.id
      rescue Stripe::CardError => e
        transaction.errors.add :base, e.message
      rescue Stripe::StripeError => e
        transaction.errors.add :base, "There was a problem with your credit card"
      end
    elsif stack.user.payment_provider_is_braintree?
      user_gateway = Braintree::Gateway.new(:merchant_id => stack.user.braintree_merchant_key,
                                            :public_key  => stack.user.braintree_api_key,
                                            :private_key => stack.user.braintree_api_secret,
                                            :environment => Rails.application.config.braintree_environment)

      charge = user_gateway.transaction.create(
        :type => 'sale',
        :amount => amount,
        :credit_card => {
          :cardholder_name => params[:name],
          :number => params[:number],
          :cvv => params[:cvv],
          :expiration_month => params[:month],
          :expiration_year => params[:year]
        },
        :billing => {
          :street_address => transaction[:billing_address_line1],
          :extended_address => transaction[:billing_address_line2],
          :locality => transaction[:billing_address_city],
          :region => transaction[:billing_address_state],
          :postal_code => transaction[:billing_address_postcode],
          :country_name => transaction[:billing_address_country]
        },
        :options => {
          :submit_for_settlement => true
        }
      )

      if charge.success?
        transaction.charge_token = charge.transaction.id
      elsif !charge.errors.nil?
        transaction.errors.add :base, charge.errors
      elsif charge.transaction.status? && charge.transaction.status == 'processor_declined'
        transaction.errors.add :base, "(#{charge.transaction.processor_response_code}) #{charge.transaction.processor_response_text}"
      elsif charge.transaction.status? && charge.transaction.status == 'gateway_rejected'
        transaction.errors.add :base, "(#{charge.transaction.gateway_rejection_code}) #{charge.transaction.gateway_rejection_reason}"
      else
        transaction.errors.add :base, "Something went wrong. Please try again."
      end
    end
    transaction
  end

  protected

  def generate_token
    random_token = 't_'

    self.transaction_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless Transaction.where(:transaction_token => random_token).exists?
    end
  end

  def send_transaction_emails
    if self.stack.send_invoice_email?
      TransactionMailer.invoice(self).deliver
    else
      TransactionMailer.recipet(self).deliver
    end
  end
end
