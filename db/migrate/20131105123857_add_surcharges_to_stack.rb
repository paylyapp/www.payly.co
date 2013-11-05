class AddSurchargesToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :require_surcharge, :boolean, :default => false
    add_column :stacks, :surcharge_value, :float
    add_column :stacks, :surcharge_unit, :string
    add_column :transactions, :surcharge_cost, :float
  end
end
