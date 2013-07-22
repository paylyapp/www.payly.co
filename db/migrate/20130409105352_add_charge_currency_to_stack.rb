class AddChargeCurrencyToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :charge_currency, :string
  end
end
