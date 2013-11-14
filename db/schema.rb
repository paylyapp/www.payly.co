# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131114190340) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "customers", :force => true do |t|
    t.string   "email"
    t.string   "user_token"
    t.string   "session_token"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "customers", ["email"], :name => "index_customers_on_email", :unique => true

  create_table "entities", :force => true do |t|
    t.string   "entity_token"
    t.string   "full_name"
    t.string   "email"
    t.string   "currency"
    t.string   "user_token"
    t.boolean  "user_entity",                         :default => false
    t.string   "encrypted_pin_api_key"
    t.string   "encrypted_pin_api_secret"
    t.string   "encrypted_stripe_api_key"
    t.string   "encrypted_stripe_api_secret"
    t.string   "encrypted_braintree_merchant_key"
    t.string   "encrypted_braintree_api_key"
    t.string   "encrypted_braintree_api_secret"
    t.string   "encrypted_braintree_client_side_key"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  create_table "failed_transactions", :force => true do |t|
    t.string   "subscription_token"
    t.text     "reason"
    t.string   "failed_transaction_token"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], :name => "impressionable_type_message_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "stacks", :force => true do |t|
    t.string   "stack_token"
    t.string   "product_name"
    t.text     "description"
    t.string   "charge_type"
    t.float    "charge_amount"
    t.string   "seller_name"
    t.string   "seller_email"
    t.string   "return_url"
    t.string   "analytics_key"
    t.boolean  "bcc_receipt"
    t.boolean  "require_shipping"
    t.boolean  "require_billing"
    t.boolean  "send_invoice_email"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "user_token"
    t.string   "charge_currency"
    t.string   "page_token"
    t.string   "primary_image_file_name"
    t.string   "primary_image_content_type"
    t.integer  "primary_image_file_size"
    t.datetime "primary_image_updated_at"
    t.string   "seller_address_line1"
    t.string   "seller_address_line2"
    t.string   "seller_address_city"
    t.integer  "seller_address_postcode"
    t.string   "seller_address_state"
    t.string   "seller_address_country"
    t.string   "seller_abn"
    t.string   "seller_trading_name"
    t.string   "invoice_number"
    t.boolean  "has_digital_download"
    t.string   "digital_download_file_file_name"
    t.string   "digital_download_file_content_type"
    t.integer  "digital_download_file_file_size"
    t.datetime "digital_download_file_updated_at"
    t.string   "digital_download_term",              :default => [],                    :array => true
    t.string   "digital_download_value",             :default => [],                    :array => true
    t.string   "digital_download_receive"
    t.boolean  "digital_download_update_flag",       :default => false
    t.boolean  "archived",                           :default => false
    t.boolean  "visible",                            :default => true
    t.string   "shipping_cost_term",                 :default => [],                    :array => true
    t.float    "shipping_cost_value",                :default => [],                    :array => true
    t.integer  "max_purchase_count"
    t.string   "ping_url"
    t.text     "custom_data_term",                   :default => [],                    :array => true
    t.text     "custom_data_value",                  :default => [],                    :array => true
    t.string   "webhook_url"
    t.boolean  "has_subscription"
    t.boolean  "require_surcharge",                  :default => false
    t.float    "surcharge_value"
    t.string   "surcharge_unit"
    t.string   "entity_token"
  end

  add_index "stacks", ["page_token"], :name => "index_stacks_on_page_token", :unique => true
  add_index "stacks", ["stack_token"], :name => "index_stacks_on_stack_token", :unique => true

  create_table "subscriptions", :force => true do |t|
    t.string   "subscription_token"
    t.integer  "stack_token"
    t.boolean  "status",                    :default => true
    t.float    "transaction_amount"
    t.float    "shipping_cost"
    t.string   "customer_token"
    t.string   "buyer_email"
    t.string   "buyer_name"
    t.string   "buyer_ip_address"
    t.string   "billing_address_line1"
    t.string   "billing_address_line2"
    t.string   "billing_address_city"
    t.string   "billing_address_postcode"
    t.string   "billing_address_state"
    t.string   "billing_address_country"
    t.string   "shipping_cost_term"
    t.float    "shipping_cost_value"
    t.string   "shipping_full_name"
    t.string   "shipping_address_line1"
    t.string   "shipping_address_line2"
    t.string   "shipping_address_city"
    t.string   "shipping_address_postcode"
    t.string   "shipping_address_state"
    t.string   "shipping_address_country"
    t.text     "custom_data_term",          :default => [],                   :array => true
    t.text     "custom_data_value",         :default => [],                   :array => true
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "card_token"
  end

  add_index "subscriptions", ["subscription_token"], :name => "index_subscriptions_on_subscription_token", :unique => true

  create_table "transactions", :force => true do |t|
    t.string   "transaction_token"
    t.integer  "stack_token"
    t.string   "charge_token"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "buyer_email"
    t.string   "buyer_ip_address"
    t.string   "card_token"
    t.string   "buyer_name"
    t.string   "shipping_address_line1"
    t.string   "shipping_address_line2"
    t.string   "shipping_address_city"
    t.string   "shipping_address_state"
    t.string   "shipping_address_country"
    t.string   "shipping_full_name"
    t.float    "transaction_amount"
    t.float    "shipping_cost"
    t.string   "shipping_cost_term"
    t.float    "shipping_cost_value"
    t.string   "charge_currency"
    t.text     "custom_data_term",          :default => [],                 :array => true
    t.text     "custom_data_value",         :default => [],                 :array => true
    t.string   "billing_address_line1"
    t.string   "billing_address_line2"
    t.string   "billing_address_city"
    t.string   "billing_address_postcode"
    t.string   "billing_address_state"
    t.string   "billing_address_country"
    t.string   "shipping_address_postcode"
    t.integer  "subscription_token"
    t.string   "customer_token"
    t.float    "surcharge_cost"
    t.float    "base_cost"
  end

  add_index "transactions", ["transaction_token"], :name => "index_transactions_on_transaction_token", :unique => true

  create_table "users", :force => true do |t|
    t.string   "user_token"
    t.string   "full_name",                           :default => "",    :null => false
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",                  :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.boolean  "tos_agreement"
    t.string   "encrypted_pin_api_key"
    t.string   "encrypted_pin_api_secret"
    t.boolean  "opt_in_communication"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "payment_method"
    t.string   "encrypted_braintree_merchant_key"
    t.string   "encrypted_braintree_api_key"
    t.string   "encrypted_braintree_api_secret"
    t.text     "encrypted_braintree_client_side_key"
    t.string   "username",                            :default => ""
    t.string   "charge_currency",                     :default => "AUD"
    t.string   "authentication_token"
    t.string   "encrypted_stripe_api_key"
    t.string   "encrypted_stripe_api_secret"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["user_token"], :name => "index_users_on_user_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
