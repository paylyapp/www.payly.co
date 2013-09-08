class AddWebhookUrlToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :webhook_url, :string
  end
end
