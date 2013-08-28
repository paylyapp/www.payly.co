class AddCurrencyToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :charge_currency, :string
  end
end
