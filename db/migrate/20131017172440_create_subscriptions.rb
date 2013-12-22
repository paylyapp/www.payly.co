class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :subscription_token
      t.integer :stack_token
      t.boolean :status, :default => true

      t.float :transaction_amount
      t.float :shipping_cost

      t.string :customer_token
      t.string :buyer_email
      t.string :buyer_name
      t.string :buyer_ip_address
      t.string :billing_address_line1
      t.string :billing_address_line2
      t.string :billing_address_city
      t.string :billing_address_postcode
      t.string :billing_address_state
      t.string :billing_address_country

      t.string :shipping_cost_term
      t.float :shipping_cost_value

      t.string :shipping_full_name
      t.string :shipping_address_line1
      t.string :shipping_address_line2
      t.string :shipping_address_city
      t.string :shipping_address_postcode
      t.string :shipping_address_state
      t.string :shipping_address_country

      t.text :custom_data_term, :array => true, :default => []
      t.text :custom_data_value, :array => true, :default => []

      t.timestamps
    end

    add_index :subscriptions, :subscription_token, :unique => true

    add_column :stacks, :has_subscription, :boolean
    add_column :transactions, :subscription_token, :string

  end
end
