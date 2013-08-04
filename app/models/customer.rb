class Customer < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :email, :user_token, :session_token

  before_create :generate_token

  has_many :transactions, :foreign_key => :buyer_email, :primary_key => :email
  has_many :customer_sessions

  validates_presence_of :email
  validates_uniqueness_of :email

  protected

  def generate_token
    random_user_token = 'u_'
    random_session_token = 's_'

    self.user_token = loop do
      random_user_token = random_user_token + SecureRandom.urlsafe_base64
      break random_user_token unless Customer.where(:user_token => random_user_token).exists?
    end
    self.session_token = loop do
      random_session_token = random_session_token + SecureRandom.urlsafe_base64
      break random_session_token unless Customer.where(:session_token => random_session_token).exists?
    end
  end
end
