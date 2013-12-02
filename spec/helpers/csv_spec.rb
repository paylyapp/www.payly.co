require 'spec_helper'
include CsvHelper

describe CsvHelper do
  describe "purchases_to_csv method" do
    it "match expected output of csv" do
      # create some objects - you have to know its values
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
      @pin_stack = FactoryGirl.create(:stack,
                                      :user_token => @pin_user.id,
                                      :charge_amount => 10)
      payload = {
            'number' => 5520000000000000,
            'expiry_month' => 05,
            'expiry_year' => 2020,
            'cvc' => 123,
            'name' => 'Tim Gleeson',
            'address_line1' => '7 Braeside Crescent',
            'address_line2' => '',
            'address_city' => 'Glen Alpine',
            'address_postcode' => 2560,
            'address_state' => 'NSW',
            'address_country' => 'Australia'
          }
      card_token = Hay::CardToken.create(@pin_user.pin_api_secret, payload)

      params = {}
      params[:transaction] = {}
      params[:transaction][:card_token] = card_token[:response][:token]
      params[:transaction][:buyer_name] = "Tim Gleeson"
      params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:transaction][:buyer_ip_address] = "101.169.255.252"
      params[:transaction][:transaction_amount] = @pin_stack.charge_amount

      transaction = Transaction.new_by_stack(params, @pin_stack)
      transaction.save!

      # you have to prepare file.csv with content from objects created above
      transactions = Transaction.all()

      expected_csv = "ID;Charge ID;Amount;Name;Email;Shipping Type;Shipping Address 1;Shipping Address 2;shipping Address City;shipping Address Postcode;shipping Address State;shipping Address Country;Created At\r\n#{transaction.transaction_token};#{transaction.charge_token};10.0;Tim Gleeson;tim.j.gleeson@gmail.com;;;;;;;;#{transaction.created_at}\r\n"
      generated_csv = purchases_to_csv(transactions)

      # sometimes it is better to parse generated_csv (ie. when you testing other formats like json or xml
      generated_csv.should == expected_csv
    end
  end

  describe "user_purchases_to_csv method" do
    it "match expected output of csv" do
      # create some objects - you have to know its values
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
      @pin_stack = FactoryGirl.create(:stack,
                                      :user_token => @pin_user.id,
                                      :charge_amount => 10)
      payload = {
            'number' => 5520000000000000,
            'expiry_month' => 05,
            'expiry_year' => 2020,
            'cvc' => 123,
            'name' => 'Tim Gleeson',
            'address_line1' => '7 Braeside Crescent',
            'address_line2' => '',
            'address_city' => 'Glen Alpine',
            'address_postcode' => 2560,
            'address_state' => 'NSW',
            'address_country' => 'Australia'
          }
      card_token = Hay::CardToken.create(@pin_user.pin_api_secret, payload)

      params = {}
      params[:transaction] = {}
      params[:transaction][:card_token] = card_token[:response][:token]
      params[:transaction][:buyer_name] = "Tim Gleeson"
      params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:transaction][:buyer_ip_address] = "101.169.255.252"
      params[:transaction][:transaction_amount] = @pin_stack.charge_amount

      transaction = Transaction.new_by_stack(params, @pin_stack)
      transaction.save!

      # you have to prepare file.csv with content from objects created above

      expected_csv = "ID;Charge ID;Amount;Name;Email;Shipping Type;Shipping Address 1;Shipping Address 2;shipping Address City;shipping Address Postcode;shipping Address State;shipping Address Country;Created At\r\n#{transaction.transaction_token};#{transaction.charge_token};10.0;Tim Gleeson;tim.j.gleeson@gmail.com;;;;;;;;#{transaction.created_at}\r\n"
      generated_csv = user_purchases_to_csv(@pin_user)

      # sometimes it is better to parse generated_csv (ie. when you testing other formats like json or xml
      generated_csv.should == expected_csv
    end
  end

  describe "stack_purchases_to_csv method" do
    it "match expected output of csv" do
      # create some objects - you have to know its values
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
      @pin_stack = FactoryGirl.create(:stack,
                                      :user_token => @pin_user.id,
                                      :charge_amount => 10)
      payload = {
            'number' => 5520000000000000,
            'expiry_month' => 05,
            'expiry_year' => 2020,
            'cvc' => 123,
            'name' => 'Tim Gleeson',
            'address_line1' => '7 Braeside Crescent',
            'address_line2' => '',
            'address_city' => 'Glen Alpine',
            'address_postcode' => 2560,
            'address_state' => 'NSW',
            'address_country' => 'Australia'
          }
      card_token = Hay::CardToken.create(@pin_user.pin_api_secret, payload)

      params = {}
      params[:transaction] = {}
      params[:transaction][:card_token] = card_token[:response][:token]
      params[:transaction][:buyer_name] = "Tim Gleeson"
      params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:transaction][:buyer_ip_address] = "101.169.255.252"
      params[:transaction][:transaction_amount] = @pin_stack.charge_amount

      transaction = Transaction.new_by_stack(params, @pin_stack)
      transaction.save!

      # you have to prepare file.csv with content from objects created above

      expected_csv = "ID;Charge ID;Amount;Name;Email;Shipping Type;Shipping Address 1;Shipping Address 2;shipping Address City;shipping Address Postcode;shipping Address State;shipping Address Country;Created At\r\n#{transaction.transaction_token};#{transaction.charge_token};10.0;Tim Gleeson;tim.j.gleeson@gmail.com;;;;;;;;#{transaction.created_at}\r\n"
      generated_csv = stack_purchases_to_csv(@pin_stack)

      # sometimes it is better to parse generated_csv (ie. when you testing other formats like json or xml
      generated_csv.should == expected_csv
    end
  end
end
