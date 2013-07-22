class AddDigitalDeliveryToStacks < ActiveRecord::Migration
  def change
    add_column :stacks, :has_digital_download, :boolean
    add_attachment :stacks, :digital_download_file
    add_column :stacks, :digital_download_term, :string, :array => true, :default => []
    add_column :stacks, :digital_download_value, :string, :array => true, :default => []
    add_column :stacks, :digital_download_receive, :string
  end
end
