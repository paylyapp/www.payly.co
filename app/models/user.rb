class User < ActiveRecord::Base
  include Gravtastic
  gravtastic :secure => true, :size => 160, :default => "http://payly.co/assets/stacks/primary_image/default/medium/logo.jpg"

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor   :current_password
  attr_accessible :user_token, :full_name, :email, :pin_api_key, :pin_api_secret,
                  :password, :password_confirmation, :current_password,
                  :remember_me, :tos_agreement, :opt_in_communication
  attr_encrypted  :pin_api_key, :key => ENV['ENCRYPT_USER_PIN_API_KEY']
  attr_encrypted  :pin_api_secret, :key => ENV['ENCRYPT_USER_PIN_API_SECRET']

  validates_presence_of :full_name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_acceptance_of :tos_agreement, :accept => true || "1", :on => :create

  has_many :stacks, :foreign_key => :user_token, :dependent => :delete_all
  has_many :transactions, :through => :stacks

  before_create :generate_token

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

  def generate_token
    random_token = 'u_'

    self.user_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless User.where(:user_token => random_token).exists?
    end
  end

end
