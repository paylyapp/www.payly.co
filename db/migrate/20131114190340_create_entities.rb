class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :entity_token
      t.string :entity_name

      t.string :full_name
      t.string :email
      t.string :currency

      t.string :user_token
      t.boolean :user_entity, :default => false

      t.string :payment_method

      t.string :encrypted_pin_api_key
      t.string :encrypted_pin_api_secret

      t.string :encrypted_stripe_api_key
      t.string :encrypted_stripe_api_secret

      t.string :encrypted_braintree_merchant_key
      t.string :encrypted_braintree_api_key
      t.string :encrypted_braintree_api_secret
      t.text :encrypted_braintree_client_side_key

      t.timestamps
    end

    add_column :stacks, :entity_token, :string

    User.find_each do |user|
      user.generate_entity
    end

    Stack.reset_column_information
    Stack.find_each do |stack|
      @token = stack.user.entity.entity_token
      stack.update_attribute(:entity_token, @token)
    end
  end
end
