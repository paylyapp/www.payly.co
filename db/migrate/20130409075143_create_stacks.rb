class CreateStacks < ActiveRecord::Migration
  def change
    create_table :stacks do |t|
      t.string :stack_token

      # Stack Details
      t.string :product_name
      t.text :description

      # Charge Details
      t.string :charge_type
      t.float :charge_amount

      # Seller Details
      t.string :seller_name
      t.string :seller_email

      # Page Information
      t.string :return_url
      t.string :ga_id

      # Extra Info
      t.boolean :bcc_receipt
      t.boolean :require_shipping
      t.boolean :require_billing
      t.boolean :send_invoice_email

      t.timestamps
    end
  end
end
