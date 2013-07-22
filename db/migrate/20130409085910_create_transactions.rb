class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :transaction_token
      t.integer :stack_token
      t.integer :transaction_amount
      t.string :customer_token
      t.string :charge_token

      t.timestamps
    end
    add_index :transactions, :transaction_token, :unique => true
  end
end
