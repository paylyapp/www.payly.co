class AddBuyerNameToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :buyer_name, :string
  end
end
