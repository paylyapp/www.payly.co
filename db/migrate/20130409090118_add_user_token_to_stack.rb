class AddUserTokenToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :user_token, :integer

    add_index :stacks, :stack_token, :unique => true
  end
end
