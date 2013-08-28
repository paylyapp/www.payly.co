class AddCurrencyToUser < ActiveRecord::Migration
  def change
    add_column :users, :charge_currency, :string, :default => 'AUD'
  end
end
