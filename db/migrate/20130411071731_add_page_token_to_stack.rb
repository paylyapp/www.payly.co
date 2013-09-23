class AddPageTokenToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :page_token, :string

    add_index :stacks, :page_token, :unique => true
  end
end
