class Stack < ActiveRecord::Base
  include Shared::AttachmentHelper

  attr_accessible :bcc_receipt, :charge_type, :charge_amount, :charge_currency, :description,
                  :ga_id, :product_name, :require_billing, :require_shipping,
                  :return_url, :seller_email, :seller_name, :page_token,
                  :user_token, :primary_image,
                  :has_digital_download, :digital_download_file, :digital_download_receive,
                  :digital_download_term, :digital_download_value, :digital_download_update_flag,
                  :send_invoice_email, :seller_trading_name, :seller_abn, :invoice_number,
                  :seller_address_line1, :seller_address_line2, :seller_address_city,
                  :seller_address_postcode, :seller_address_state, :seller_address_country,
                  :shipping_cost_value, :shipping_cost_term,
                  :archive, :visible

  belongs_to :user, :foreign_key => :user_token
  has_many :transactions, :foreign_key => :stack_token

  has_attached_file :primary_image, :s3_protocol => 'https', :s3_permissions => 'public_read', :styles => {:tiny => '50x50#', :small => '100x100#', :medium => '200x200#', :large => '400x400#'}, :default_url => "/assets/stacks/primary_image/default/:style/logo.jpg"
  has_attachment :digital_download_file

  validates :product_name, :presence => { :message => "This page must have a name." }
  validates :charge_amount, :presence => { :message => "This page must have an amount." }, :if => :charge_type_is_fixed?
  validates :charge_amount, :numericality => { :message => "The amount must be numerical." }, :if => :charge_type_is_fixed?
  validates :description, :presence => { :message => "This page must have a description." }
  validates_attachment_size :primary_image, :less_than => 1.megabytes
  validates_attachment_content_type :primary_image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates :page_token, :presence => { :message => "This page must have a slug." }
  validates :page_token, :uniqueness => { :message => "The slug has already been used." }
  validates :seller_name, :presence => { :message => "This page must have the seller's name." }
  validates :seller_email, :presence => { :message => "This page must have the seller's email." }
  validates :seller_trading_name, :presence => { :message => "This page must have the seller's trading name." }, :if => :sending_an_invoice?
  validates :seller_abn, :presence => { :message => "This page must have the seller's ABN." }, :if => :sending_an_invoice?
  validates :seller_address_line1, :presence => { :message => "This page must have the seller's address line 1." }, :if => :sending_an_invoice?
  validates :seller_address_city, :presence => { :message => "This page must have the seller's city." }, :if => :sending_an_invoice?
  validates :seller_address_postcode, :presence => { :message => "This page must have the seller's postcode." }, :if => :sending_an_invoice?
  validates :seller_address_state, :presence => { :message => "This page must have the seller's state." }, :if => :sending_an_invoice?
  validates :seller_address_country, :presence => { :message => "This page must have the seller's country." }, :if => :sending_an_invoice?


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

  # remove old unnecessary data
  # must keep product name, currency charged,
  # seller name, seller email, required shipping
  def decommission
    self.archived = true
    self.visible = false
    self.primary_image = nil
    self.digital_download_file = nil
    self.ga_id = nil
    self.return_url = nil
    self.save!
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
  end
end
