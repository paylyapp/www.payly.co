class AddDetailsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :shipping_full_name, :string
  end
end
