class AddOptInCommunicationtoUser < ActiveRecord::Migration
  def change
    add_column :users, :opt_in_communication, :boolean
  end
end
