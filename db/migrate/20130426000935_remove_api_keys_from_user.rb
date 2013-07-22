class RemoveApiKeysFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :pin_api_key
    remove_column :users, :pin_api_secret
  end

  def down
    add_column :users, :pin_api_secret, :string
    add_column :users, :pin_api_key, :string
  end
end
