class AddUpdatedEmailFlagToStacks < ActiveRecord::Migration
  def change
    add_column :stacks, :digital_download_update_flag, :boolean, :default => false
  end
end
