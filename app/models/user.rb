class User < ActiveRecord::Base
  include Gravtastic
  gravtastic :secure => true, :size => 160, :default => "http://payly.co/assets/stacks/primary_image/default/medium/logo.jpg"

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor   :current_password
  attr_accessible :user_token, :full_name, :email, :pin_api_key, :pin_api_secret,
                  :password, :password_confirmation, :current_password, 
                  :remember_me, :tos_agreement
  attr_encrypted  :pin_api_key, :key => 'b8da62e46fe69b78df264408e03ab32fc9ad4b224dc2f28fafc868a0af0e7995acacb46d1e296011e19bf2ed54200d518795460b3c5e54817fe4a62c7c68f151'
  attr_encrypted  :pin_api_secret, :key => '0fb5ac9a27150b79f1cf4bb08c123d951f2f476b571e9923120b796ff0928d217e14b64b9ad185bcb90594c5ea2f7e19ef2788ca1e82c88d2dff47aed7ec3328'
  
  validate :full_name, :presence => true, :message => "We require your full name."
  validate :email, :presence => true, :message => "We require your email address."
  validate :email, :uniqueness => true, :message => "That email address is already in use."
  validates_acceptance_of :tos_agreement, :accept => true || "1", :on => :create

  has_many :stacks, :foreign_key => :user_token, :dependent => :delete_all
  has_many :transactions, :through => :stacks

  before_create :generate_token
  after_create :send_welcome_email

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

  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end

end
