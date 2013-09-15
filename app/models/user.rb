class User < ActiveRecord::Base
  include Gravtastic
  gravtastic :secure => true, :size => 160, :default => "http://payly.co/assets/stacks/primary_image/default/medium/logo.jpg"

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor   :current_password
  attr_accessible :user_token, :full_name, :email, :username,
                  :password, :password_confirmation, :current_password,
                  :remember_me, :tos_agreement, :opt_in_communication,
                  :payment_method,
                  :pin_api_key, :pin_api_secret,
                  :stripe_api_key, :stripe_api_secret,
                  :braintree_merchant_id, :braintree_api_key, :braintree_api_secret, :braintree_client_side_key,
                  :charge_currency

  attr_encrypted  :pin_api_key, :key => ENV['ENCRYPT_USER_PIN_API_KEY']
  attr_encrypted  :pin_api_secret, :key => ENV['ENCRYPT_USER_PIN_API_SECRET']

  attr_encrypted  :stripe_api_key, :key => ENV['ENCRYPT_USER_STRIPE_API_KEY']
  attr_encrypted  :stripe_api_secret, :key => ENV['ENCRYPT_USER_STRIPE_API_SECRET']

  attr_encrypted  :braintree_merchant_id, :key => ENV['ENCRYPT_USER_BRAINTREE_MERCHANT_ID']
  attr_encrypted  :braintree_api_key, :key => ENV['ENCRYPT_USER_BRAINTREE_API_KEY']
  attr_encrypted  :braintree_api_secret, :key => ENV['ENCRYPT_USER_BRAINTREE_API_SECRET']
  attr_encrypted  :braintree_client_side_key, :key => ENV['ENCRYPT_USER_BRAINTREE_CLIENT_SIDE_KEY']

  validates_presence_of :full_name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_acceptance_of :tos_agreement, :accept => true || "1", :on => :create

  has_many :stacks, :foreign_key => :user_token
  has_many :transactions, :through => :stacks

  before_create :generate_token
  before_destroy :hide_owned_stacks
  before_save :ensure_authentication_token

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def weekly_stats
    transactions = self.transactions.where('"transactions"."created_at" BETWEEN ? AND ?', Time.now.beginning_of_week(start_day = :sunday), Time.now)
    count = 0
    cost = 0
    transactions.each do |transaction|
      if transaction.stack.archived == false
        cost = cost + transaction.transaction_amount
        count = count + 1
      end
    end

    stats = {:count => count, :cost => cost}

    stats
  end

  def monthly_stats
    transactions = self.transactions.where('"transactions"."created_at" BETWEEN ? AND ?', Time.now.beginning_of_month, Time.now)
    count = 0
    cost = 0
    transactions.each do |transaction|
      if transaction.stack.archived == false
        cost = cost + transaction.transaction_amount
        count = count + 1
      end
    end

    stats = {:count => count, :cost => cost}
    stats
  end

  def all_stats
    transactions = self.transactions.all
    count = 0
    cost = 0
    transactions.each do |transaction|
      if transaction.stack.archived == false
        cost = cost + transaction.transaction_amount
        count = count + 1
      end
    end

    stats = {:count => count, :cost => cost}
    stats
  end

  def has_payment_provider?
    if self.payment_provider_is_pin_payments?
      true
    elsif self.payment_provider_is_stripe?
      true
    elsif self.payment_provider_is_braintree?
      true
    else
      false
    end
  end

  def has_payment_provider_keys?
    if self.has_pin_payment_keys?
      true
    elsif self.has_strip_keys?
      true
    elsif self.has_braintree_keys?
      true
    else
      false
    end
  end

  def payment_provider_is_pin_payments?
    self.payment_method == 'pin_payments' && (!self.pin_api_key.blank? && !self.pin_api_secret.blank?)
  end

  def has_pin_payment_keys?
    self.payment_method == 'pin_payments' && (self.pin_api_key.blank? || self.pin_api_secret.blank?)
  end

  def payment_provider_is_stripe?
    self.payment_method == 'stripe' && (!self.stripe_api_key.blank? && !self.stripe_api_secret.blank?)
  end

  def has_stripe_keys?
    self.payment_method == 'stripe' && (self.stripe_api_key.blank? || self.stripe_api_secret.blank?)
  end

  def payment_provider_is_braintree?
    self.payment_method == 'braintree' && (!self.braintree_merchant_id.blank? && !self.braintree_api_key.blank? && !self.braintree_api_secret.blank? || self.braintree_client_side_key.blank?)
  end

  def has_braintree_keys?
    self.payment_method == 'braintree' && (self.braintree_merchant_id.blank? || self.braintree_api_key.blank? || self.braintree_api_secret.blank? || self.braintree_client_side_key.blank?)
  end

  protected

  def hide_owned_stacks
    stacks = Stack.where(:user_token => self.id)

    stacks.each do |stack|
      stack.decommission
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def generate_token
    random_token = 'u_'

    self.user_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless User.where(:user_token => random_token).exists?
    end
  end

end
