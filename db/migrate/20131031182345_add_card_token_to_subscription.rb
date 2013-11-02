class AddCardTokenToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :card_token, :string
  end
end
