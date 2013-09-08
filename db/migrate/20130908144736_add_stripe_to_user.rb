class AddStripeToUser < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_stripe_api_key, :string
    add_column :users, :encrypted_stripe_api_secret, :string
  end
end
