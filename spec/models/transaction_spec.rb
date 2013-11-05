require 'spec_helper'

describe Transaction do
  describe 'using Pin payments' do
    before :each do
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
    end

    describe "charge $10.00" do
      it "default" do
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

        transaction.transaction_amount.should == 10
        transaction.errors.empty?.should == true

        charge = Hay::Charges.show(@pin_user.pin_api_secret, transaction.charge_token)
        (transaction.transaction_amount * 100).should == charge[:response][:amount]
      end

      describe "with shipping" do
        it "default" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_shipping => true,
                                          :shipping_cost_value => [10.95, 29.95],
                                          :shipping_cost_term => ['Domestic', 'International'])
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
          params[:transaction][:shipping_cost] = 0
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.transaction_amount.should == 20.95
          transaction.shipping_cost_value.should == 10.95
          transaction.shipping_cost_term.should == 'Domestic'
          transaction.errors.empty?.should == true

          charge = Hay::Charges.show(@pin_user.pin_api_secret, transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:response][:amount]
        end
      end

      describe "with surcharge" do
        it "of 10%" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_surcharge => true,
                                          :surcharge_value => 10,
                                          :surcharge_unit => 'percentage')
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

          transaction.transaction_amount.should == 11
          transaction.surcharge_cost.should == 1
          transaction.errors.empty?.should == true

          charge = Hay::Charges.show(@pin_user.pin_api_secret, transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:response][:amount]
        end

        it "of $5.95" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_surcharge => true,
                                          :surcharge_value => 5.95,
                                          :surcharge_unit => 'dollar')
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

          transaction.transaction_amount.should == 15.95
          transaction.surcharge_cost.should == 5.95
          transaction.errors.empty?.should == true

          charge = Hay::Charges.show(@pin_user.pin_api_secret, transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:response][:amount]
        end
      end
    end
  end
end