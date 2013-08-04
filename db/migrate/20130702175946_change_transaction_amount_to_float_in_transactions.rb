class ChangeTransactionAmountToFloatInTransactions < ActiveRecord::Migration
  def up
    rename_column :transactions, :transaction_amount, :transaction_amount_integer
    add_column :transactions, :transaction_amount, :float

    Transaction.reset_column_information
    Transaction.find_each { |c| c.update_attribute(:transaction_amount, c.transaction_amount_integer) }
    remove_column :transactions, :transaction_amount_integer
  end

  def down
  end
end
