class AddSellerAddressDetailsToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :seller_address_line1, :string
    add_column :stacks, :seller_address_line2, :string
    add_column :stacks, :seller_address_city, :string
    add_column :stacks, :seller_address_postcode, :integer
    add_column :stacks, :seller_address_state, :string
    add_column :stacks, :seller_address_country, :string
  end
end
