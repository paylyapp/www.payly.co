class Transaction < ActiveRecord::Base
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

  # def ping_url
  #   if !self.stack.nil?
  #     iron_worker = IronWorkerNG::Client.new
  #     iron_worker.tasks.create("ping", self)
  #   end
  # end

  def webhook_url
    unless self.stack.nil? && self.stack.webhook_url.nil?
      opts = {
        :method => 'POST',
        :url => self.stack.webhook_url,
        :timeout => 30
      }

      begin
        response = RestClient::Request.execute(opts)
      rescue SocketError => e
        send_warning_email_to_seller(false, e)
      rescue NoMethodError => e
        if e.message =~ /\WRequestFailed\W/
          e = APIConnectionError.new('Unexpected HTTP response code')
          send_warning_email_to_seller(false, e)
        else
          send_warning_email_to_seller(false, 'Something went wrong')
        end
      rescue RestClient::ExceptionWithResponse => e
        if rcode = e.http_code and rbody = e.http_body
          send_warning_email_to_seller(rcode, rbody)
        else
          send_warning_email_to_seller(false, e)
        end
      rescue RestClient::Exception, Errno::ECONNREFUSED => e
        send_warning_email_to_seller(false, e)
      end
    end
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

  def send_warning_email_to_seller(code, body)
    puts "#{code}"
    puts "#{body}"
  end
end
