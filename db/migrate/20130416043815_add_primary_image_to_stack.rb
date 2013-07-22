class AddPrimaryImageToStack < ActiveRecord::Migration
  def self.up
    add_attachment :stacks, :primary_image
  end

  def self.down
    remove_attachment :stacks, :primary_image
  end
end
