class AddBraintreetoUser < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_braintree_merchant_id, :string
    add_column :users, :encrypted_braintree_api_key, :string
    add_column :users, :encrypted_braintree_api_secret, :string
  end
end
