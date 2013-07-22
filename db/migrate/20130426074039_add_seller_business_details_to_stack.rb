class AddSellerBusinessDetailsToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :seller_abn, :string
    add_column :stacks, :seller_trading_name, :string
    add_column :stacks, :invoice_number, :string
  end
end
