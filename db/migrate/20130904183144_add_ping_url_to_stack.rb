class AddPingUrlToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :ping_url, :string
  end
end
