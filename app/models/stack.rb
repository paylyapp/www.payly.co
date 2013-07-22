class Stack < ActiveRecord::Base
  include Shared::AttachmentHelper

  attr_accessible :bcc_receipt, :charge_type, :charge_amount, :charge_currency, :description,
                  :ga_id, :product_name, :require_billing, :require_shipping,
                  :return_url, :seller_email, :seller_name,
                  :user_token, :primary_image,
                  :has_digital_download, :digital_download_file, :digital_download_receive,
                  :digital_download_term, :digital_download_value, :digital_download_update_flag,
                  :send_invoice_email, :seller_trading_name, :seller_abn, :invoice_number,
                  :seller_address_line1, :seller_address_line2, :seller_address_city,
                  :seller_address_postcode, :seller_address_state, :seller_address_country,
                  :shipping_cost_value, :shipping_cost_term

  belongs_to :user, :foreign_key => :user_token
  has_many :transactions, :foreign_key => :stack_token, :dependent => :delete_all

  has_attached_file :primary_image, :styles => {:tiny => '50x50#', :small => '100x100#', :medium => '200x200#', :large => '400x400#'}, :default_url => "/assets/stacks/primary_image/default/:style/logo.jpg"
  has_attachment :digital_download_file

  validates :product_name, :presence => true
  validates :charge_amount, :presence => true, :if => :charge_type_is_fixed?
  validates :charge_amount, :numericality => true, :if => :charge_type_is_fixed?
  validates :description, :presence => true
  validates_attachment_size :primary_image, :less_than => 1.megabytes
  validates_attachment_content_type :primary_image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates :seller_name, :presence => true
  validates :seller_email, :presence => true
  validates :seller_trading_name, :presence => true, :if => :sending_an_invoice?
  validates :seller_abn, :presence => true, :if => :sending_an_invoice?
  validates :seller_address_line1, :presence => true, :if => :sending_an_invoice?
  validates :seller_address_city, :presence => true, :if => :sending_an_invoice?
  validates :seller_address_postcode, :presence => true, :if => :sending_an_invoice?
  validates :seller_address_state, :presence => true, :if => :sending_an_invoice?
  validates :seller_address_country, :presence => true, :if => :sending_an_invoice?


  validates_attachment_size :digital_download_file, :less_than => 10.megabytes

  before_create :generate_tokens
  before_create :set_currency

  def charge_type_is_fixed?
    charge_type == "fixed"
  end

  def sending_an_invoice?
    send_invoice_email == true
  end

  def can_delivery_file?
    true
  end

  def weekly_stats
    transactions = self.transactions.where('"transactions"."created_at" BETWEEN ? AND ?', Time.now.beginning_of_week(start_day = :sunday), Time.now)
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.stack.charge_amount
    end

    stats = {:count => count, :cost => cost}

    stats
  end

  def monthly_stats
    transactions = self.transactions.where('"transactions"."created_at" BETWEEN ? AND ?', Time.now.beginning_of_month, Time.now)
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.stack.charge_amount
    end

    stats = {:count => count, :cost => cost}
    stats
  end

  def all_stats
    transactions = self.transactions.all
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.stack.charge_amount
    end

    stats = {:count => count, :cost => cost}
    stats
  end

  protected

  def set_currency
    self.charge_currency = "AUD"
  end

  def generate_tokens
    random_token = 's_'

    self.stack_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless Stack.where(:stack_token => random_token).exists?
    end

    self.page_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Stack.where(:page_token => random_token).exists?
    end
  end
end
