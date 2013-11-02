class AddCustomerTokenToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :customer_token, :string
  end
end
