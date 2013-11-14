class Entity < ActiveRecord::Base
  attr_accessible :entity_token,
                  :full_name, :email, :currency,
                  :user_token, :user_entity,
                  :pin_api_key, :pin_api_secret,
                  :stripe_api_key, :stripe_api_secret,
                  :braintree_merchant_key, :braintree_api_key, :braintree_api_secret, :braintree_client_side_key

  attr_encrypted  :pin_api_key, :key => ENV['ENCRYPT_ENTITY_PIN_API_KEY']
  attr_encrypted  :pin_api_secret, :key => ENV['ENCRYPT_ENTITY_PIN_API_SECRET']

  attr_encrypted  :stripe_api_key, :key => ENV['ENCRYPT_ENTITY_STRIPE_API_KEY']
  attr_encrypted  :stripe_api_secret, :key => ENV['ENCRYPT_ENTITY_STRIPE_API_SECRET']

  attr_encrypted  :braintree_merchant_key, :key => ENV['ENCRYPT_ENTITY_BRAINTREE_MERCHANT_ID']
  attr_encrypted  :braintree_api_key, :key => ENV['ENCRYPT_ENTITY_BRAINTREE_API_KEY']
  attr_encrypted  :braintree_api_secret, :key => ENV['ENCRYPT_ENTITY_BRAINTREE_API_SECRET']
  attr_encrypted  :braintree_client_side_key, :key => ENV['ENCRYPT_ENTITY_BRAINTREE_CLIENT_SIDE_KEY']

  # validates_presence_of :entity_token

  validates_presence_of :full_name
  validates_presence_of :email
  validates_presence_of :currency

  validates_presence_of :user_token

  belongs_to :user, :foreign_key => :user_token, :primary_key => :user_token

  has_many :stacks, :foreign_key => :entity_token, :primary_key => :entity_token
  has_many :transactions, :through => :stacks

  before_create :generate_token

  def self.new_by_user(params, user)
    entity = self.new(params[:entity])
    entity.user_token = user.user_token

    entity
  end

  protected

  def generate_token
    random_token = 'e_'

    self.entity_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless Entity.where(:entity_token => random_token).exists?
    end
  end
end
