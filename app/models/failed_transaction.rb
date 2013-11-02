class FailedTransaction < ActiveRecord::Base
  attr_accessible :failed_transaction_token, :reason, :subscription_token

  before_create :generate_token

  protected

  def generate_token
    random_token = 't_'

    self.failed_transaction_token = loop do
      random_token = random_token + SecureRandom.urlsafe_base64
      break random_token unless FailedTransaction.where(:failed_transaction_token => random_token).exists?
    end
  end
end
