class AddBillingDetailsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :billing_address_line1, :string
    add_column :transactions, :billing_address_line2, :string
    add_column :transactions, :billing_address_city, :string
    add_column :transactions, :billing_address_postcode, :string
    add_column :transactions, :billing_address_state, :string
    add_column :transactions, :billing_address_country, :string

    rename_column :transactions, :shipping_address_postcode, :shipping_address_postcode_integer
    add_column :transactions, :shipping_address_postcode, :string

    Transaction.reset_column_information
    Transaction.find_each { |c| c.update_attribute(:shipping_address_postcode, c.shipping_address_postcode_integer) }
    remove_column :transactions, :shipping_address_postcode_integer
  end
end
