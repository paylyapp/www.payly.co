class RemoveCustomerTokenAndAddCardTokenToTransaction < ActiveRecord::Migration
  def up
    add_column :transactions, :card_token, :string
    remove_column :transactions, :customer_token
  end

  def down
    remove_column :transactions, :card_token
    add_column :transactions, :customer_token, :string
  end
end
