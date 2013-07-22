class AddBuyerDetailsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :buyer_email, :string
    add_column :transactions, :buyer_ip_address, :string
  end
end
