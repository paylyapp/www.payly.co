class Transaction < ActiveRecord::Base
  attr_accessible :transaction_token, :transaction_amount,
                  :buyer_email, :buyer_name, :buyer_ip_address,
                  :charge_token, :card_token,
                  :stack_token,
                  :shipping_full_name,
                  :shipping_address_line1, :shipping_address_line2, :shipping_address_city,
                  :shipping_address_postcode, :shipping_address_state, :shipping_address_country

  belongs_to :stack, :foreign_key => :stack_token
  belongs_to :customer

  validates :buyer_name, :presence => true
  validates :buyer_email, :presence => true
  validates :transaction_amount, :presence => true

  before_create :generate_token
  after_create :send_transaction_emails

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
