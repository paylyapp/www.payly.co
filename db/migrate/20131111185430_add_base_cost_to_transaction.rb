class AddBaseCostToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :base_cost, :float
  end
end
