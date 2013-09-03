class AddMaxPurchaseCountToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :max_purchase_count, :integer
  end
end
