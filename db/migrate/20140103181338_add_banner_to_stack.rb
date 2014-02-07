class AddBannerToStack < ActiveRecord::Migration
  def self.up
    add_attachment :stacks, :banner_image
  end

  def self.down
    remove_attachment :stacks, :banner_image
  end
end
