class AddShippingCost < ActiveRecord::Migration
  def change
    add_column :stacks, :shipping_cost_term, :string, :array => true, :default => []
    add_column :stacks, :shipping_cost_value, :float, :array => true, :default => []
    add_column :transactions, :shipping_cost, :float
    add_column :transactions, :shipping_cost_term, :string
    add_column :transactions, :shipping_cost_value, :float
  end
end
