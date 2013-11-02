class CreateFailedTransactions < ActiveRecord::Migration
  def change
    create_table :failed_transactions do |t|
      t.string :subscription_token
      t.text :reason
      t.string :failed_transaction_token

      t.timestamps
    end

    # add_index :failed_transactions, :subscription_token, :unique => true
  end
end
