class AddPaymentMethodToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payment_method, :string

    User.find_each { |c| c.update_attribute(:payment_method, 'pin_payments') }
  end
end
