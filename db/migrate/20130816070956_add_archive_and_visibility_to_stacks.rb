class AddArchiveAndVisibilityToStacks < ActiveRecord::Migration
  def change
    add_column :stacks, :archived, :boolean, :default => false
    add_column :stacks, :visible, :boolean, :default => true
  end
end
