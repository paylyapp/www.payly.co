class AddEncryptedApiKeysToUser < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_pin_api_key, :string
    add_column :users, :encrypted_pin_api_secret, :string
  end
end
