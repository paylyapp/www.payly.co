class AddBuyButtonTextToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :buy_button_text, :string, :default => 'Buy this'
  end
end
