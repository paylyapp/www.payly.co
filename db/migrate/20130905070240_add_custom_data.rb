class AddCustomData < ActiveRecord::Migration
  def change
    add_column :stacks, :custom_data_term, :text, :array => true, :default => []
    add_column :stacks, :custom_data_value, :text, :array => true, :default => []
    add_column :transactions, :custom_data_term, :text, :array => true, :default => []
    add_column :transactions, :custom_data_value, :text, :array => true, :default => []
  end
end
