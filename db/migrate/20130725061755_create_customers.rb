class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|

      t.string :email, :unique => true
      t.string :user_token, :unique => true
      t.string :session_token, :unique => true

      t.timestamps
    end

    add_index :customers, :email, :unique => true
  end
end
