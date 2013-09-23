class FixIdNaming < ActiveRecord::Migration
  def change
    rename_column :users, :encrypted_braintree_merchant_id, :encrypted_braintree_merchant_key
    rename_column :stacks, :ga_id, :analytics_key
  end
end
