class Transaction < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  attr_accessible :transaction_token, :transaction_amount,
                  :buyer_email, :buyer_name, :buyer_ip_address,
                  :charge_token, :card_token,
                  :stack_token,
                  :shipping_cost, :shipping_cost_term, :shipping_cost_value,
                  :shipping_full_name, :shipping_address_line1, :shipping_address_line2,
                  :shipping_address_city, :shipping_address_postcode, :shipping_address_state,
                  :shipping_address_country,
                  :custom_data_term, :custom_data_value

  belongs_to :stack, :foreign_key => :stack_token
  belongs_to :customer

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
    purchase[:payed] = number_to_currency(self.transaction_amount, :precision => 2)
    purchase[:shipping] = {}
      purchase[:shipping][:type] = self.shipping_cost_term
      purchase[:shipping][:payed] = number_to_currency(self.shipping_cost, :precision => 2)
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
        custom_field[:name] = self.custom_data_term[index]
        custom_field[:value] = self.custom_data_value[index]
        purchase[:custom_fields] << custom_field
      end
    end
    purchase
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
    if self.stack.send_invoice_email == true
      TransactionMailer.invoice(self).deliver
    else
      TransactionMailer.recipet(self).deliver
    end
  end
end
