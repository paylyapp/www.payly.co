class Stack < ActiveRecord::Base
  include Shared::AttachmentHelper
  include ActionView::Helpers::NumberHelper

  is_impressionable

  attr_accessible :bcc_receipt, :charge_type, :charge_amount, :charge_currency, :page_token, :description,
                  :ga_id, :product_name, :require_billing,
                  :require_shipping, :shipping_cost_value, :shipping_cost_term,
                  :return_url, :ping_url, :seller_email, :seller_name,
                  :user_token, :primary_image,
                  :has_digital_download, :digital_download_file, :digital_download_receive,
                  :digital_download_term, :digital_download_value, :digital_download_update_flag,
                  :send_invoice_email, :seller_trading_name, :seller_abn, :invoice_number,
                  :seller_address_line1, :seller_address_line2, :seller_address_city,
                  :seller_address_postcode, :seller_address_state, :seller_address_country,
                  :archived, :visible, :max_purchase_count,
                  :custom_data_term, :custom_data_value

  belongs_to :user, :foreign_key => :user_token
  has_many :transactions, :foreign_key => :stack_token

  has_attached_file :primary_image, :s3_protocol => 'https', :s3_permissions => 'public_read', :styles => {:tiny => '50x50#', :small => '100x100#', :medium => '200x200#', :large => '400x400#'}, :default_url => "/assets/stacks/primary_image/default/:style/logo.jpg"
  has_attachment :digital_download_file

  validates :product_name, :presence => { :message => "This page must have a name." }
  validates :charge_amount, :presence => { :message => "This page must have an amount." }, :if => :charge_type_is_fixed?
  validates :charge_amount, :numericality => { :message => "The amount must be numerical." }, :if => :charge_type_is_fixed?
  validates :description, :presence => { :message => "This page must have a description." }, :if => :not_decommisioned?
  validates_attachment_size :primary_image, :less_than => 1.megabytes
  validates_attachment_content_type :primary_image, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates :page_token, :presence => { :message => "This page must have a slug." }, :if => :not_decommisioned?
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

  def throw_transaction_error?(current_user)
    if self.archived
      true
    else
      if self.user.nil?
        true
      else
        if self.visible == false && (!current_user || current_user.id != self.user.id)
          true
        else
          if self.user.payment_method.blank?
            true
          else
            if !self.max_purchase_count.nil? && self.max_purchase_count <= self.transactions.count
              true
            else
              false
            end
          end
        end
      end
    end
  end

  def shipping_cost_array
    unless self.shipping_cost_term.blank?
      shipping_cost = []
      self.shipping_cost_term.each_index { |index|
        cost = []

        cost << self.shipping_cost_term[index] + ' - $' + number_with_precision(self.shipping_cost_value[index], :precision => 2) + 'AUD'
        cost << index
        cost << {:"data-value" => number_with_precision(self.shipping_cost_value[index], :precision => 2)}
        shipping_cost << cost
      }
    else
      shipping_cost = false
    end
    shipping_cost
  end

  def not_decommisioned?
    !self.archived
  end

  def api_array
    page = {}
    page[:id] = self.stack_token
    page[:name] = self.product_name
    page[:description] = self.description
    page[:logo] = self.primary_image.url
    page[:permalink] = "http://#{Rails.application.config.action_mailer.default_url_options[:host]}/p/" + self.page_token
    page[:price] = self.charge_amount.nil? ? nil : self.charge_amount * 100
    page[:formated_price] = self.charge_amount.nil? ? nil : number_to_currency(self.charge_amount, :precision => 2)
    page[:purchase_count] = {}
      page[:purchase_count][:maximum] = self.max_purchase_count.nil? ? 999999 : self.max_purchase_count
      page[:purchase_count][:current] = self.transactions.count
    page[:digital_download] = {}
      page[:digital_download][:url] = self.digital_download_file.expiring_url(3600)
      page[:digital_download][:description] = self.digital_download_receive
    page[:seller] = {}
      page[:seller][:name] = self.seller_name
      page[:seller][:email] = self.seller_email
      page[:seller][:trading_name] = self.seller_trading_name
      page[:seller][:abn] = self.seller_abn
      page[:seller][:address_line1] = self.seller_address_line1
      page[:seller][:address_line2] = self.seller_address_line2
      page[:seller][:address_city] = self.seller_address_city
      page[:seller][:address_postcode] = self.seller_address_postcode
      page[:seller][:address_state] = self.seller_address_state
      page[:seller][:address_country] = self.seller_address_country
    page[:custom_fields] = []
    unless self.custom_data_term.blank?
      self.custom_data_term.each_index do |index|
        custom_field = {}
        custom_field[:name] = self.custom_data_term[index]
        custom_field[:required] = self.custom_data_value[index].nil? ? false : true
        page[:custom_fields] << custom_field
      end
    end
    page[:purchases] = []
    self.transactions.limit(5).each do |transaction|
      page[:purchases] << transaction.api_array
    end
    page
  end

  def weekly_stats
    transactions = self.transactions.where('"transactions"."created_at" BETWEEN ? AND ?', Time.now.beginning_of_week(start_day = :sunday), Time.now)
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.transaction_amount
    end

    stats = {:count => count, :cost => cost}

    stats
  end

  def monthly_stats
    transactions = self.transactions.where('"transactions"."created_at" BETWEEN ? AND ?', Time.now.beginning_of_month, Time.now)
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.transaction_amount
    end

    stats = {:count => count, :cost => cost}
    stats
  end

  def all_stats
    transactions = self.transactions.all
    count = transactions.count
    cost = 0
    transactions.each do |transaction|
      cost += transaction.transaction_amount
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
    self.has_digital_download = false
    self.charge_type = nil
    self.charge_amount = 0
    self.primary_image = nil
    self.digital_download_file = nil
    self.ga_id = nil
    self.return_url = nil
    self.description = nil
    self.page_token = nil
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
