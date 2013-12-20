require 'spec_helper'

describe Transaction do

  it "should have relationship" do
    should belong_to(:stack)
    should belong_to(:subscription)
  end

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
        transaction.save!

        email = ActionMailer::Base.deliveries.last
        email.should deliver_to("tim.j.gleeson@gmail.com")
        email.should_not have_body_text(/Surcharge/)
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
          transaction.save!

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
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
          transaction.save!

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
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
          transaction.save!

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end
      end

      describe "sends invoice" do
        it "default" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :send_invoice_email => true,
                                          :seller_trading_name => 'ABC',
                                          :seller_abn => '123',
                                          :seller_address_line1 => '1 Street',
                                          :seller_address_city => 'City',
                                          :seller_address_postcode => '123',
                                          :seller_address_state => 'ABC',
                                          :seller_address_country => 'AUD')
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
          transaction.save!

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end

        describe "with shipping" do
          it "default" do
            @pin_stack = FactoryGirl.create(:stack,
                                            :user_token => @pin_user.id,
                                            :charge_amount => 10,
                                            :require_shipping => true,
                                            :shipping_cost_value => [10.95, 29.95],
                                            :shipping_cost_term => ['Domestic', 'International'],
                                            :send_invoice_email => true,
                                            :seller_trading_name => 'ABC',
                                            :seller_abn => '123',
                                            :seller_address_line1 => '1 Street',
                                            :seller_address_city => 'City',
                                            :seller_address_postcode => '123',
                                            :seller_address_state => 'ABC',
                                            :seller_address_country => 'AUD')
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
            transaction.save!

            email = ActionMailer::Base.deliveries.last
            email.should deliver_to("tim.j.gleeson@gmail.com")
            email.should_not have_body_text(/Surcharge/)
          end
        end

        describe "with surcharge" do
          it "of 10%" do
            @pin_stack = FactoryGirl.create(:stack,
                                            :user_token => @pin_user.id,
                                            :charge_amount => 10,
                                            :require_surcharge => true,
                                            :surcharge_value => 10,
                                            :surcharge_unit => 'percentage',
                                            :send_invoice_email => true,
                                            :seller_trading_name => 'ABC',
                                            :seller_abn => '123',
                                            :seller_address_line1 => '1 Street',
                                            :seller_address_city => 'City',
                                            :seller_address_postcode => '123',
                                            :seller_address_state => 'ABC',
                                            :seller_address_country => 'AUD')
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
            transaction.save!

            email = ActionMailer::Base.deliveries.last
            email.should deliver_to("tim.j.gleeson@gmail.com")
            email.should have_body_text(/Surcharge/)
          end

          it "of $5.95" do
            @pin_stack = FactoryGirl.create(:stack,
                                            :user_token => @pin_user.id,
                                            :charge_amount => 10,
                                            :require_surcharge => true,
                                            :surcharge_value => 5.95,
                                            :surcharge_unit => 'dollar',
                                            :send_invoice_email => true,
                                            :seller_trading_name => 'ABC',
                                            :seller_abn => '123',
                                            :seller_address_line1 => '1 Street',
                                            :seller_address_city => 'City',
                                            :seller_address_postcode => '123',
                                            :seller_address_state => 'ABC',
                                            :seller_address_country => 'AUD')
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
            transaction.save!

            email = ActionMailer::Base.deliveries.last
            email.should deliver_to("tim.j.gleeson@gmail.com")
            email.should have_body_text(/Surcharge/)
          end
        end
      end
    end
  end

  describe 'using Stripe' do
    before :each do
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'stripe', :stripe_api_key => ENV['STRIPE_PUBLISHABLE_KEY'], :stripe_api_secret => ENV['STRIPE_SECRET_KEY'])
    end

    describe "charge $10.00" do
      it "default" do
        @pin_stack = FactoryGirl.create(:stack,
                                        :user_token => @pin_user.id,
                                        :charge_amount => 10)

        Stripe.api_key = @pin_user.stripe_api_secret

        card_token = Stripe::Token.create(
          :card => {
            :number => 5555555555554444,
            :exp_month => 10,
            :exp_year => 2014,
            :cvc => "314"
          }
        )

        params = {}
        params[:transaction] = {}
        params[:transaction][:card_token] = card_token[:id]
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:transaction_amount] = @pin_stack.charge_amount

        transaction = Transaction.new_by_stack(params, @pin_stack)

        transaction.base_cost.should == 10.00
        transaction.transaction_amount.should == 10
        transaction.errors.empty?.should == true

        charge = Stripe::Charge.retrieve(transaction.charge_token)
        (transaction.transaction_amount * 100).should == charge[:amount]
      end

      describe "with shipping" do
        it "default" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_shipping => true,
                                          :shipping_cost_value => [10.95, 29.95],
                                          :shipping_cost_term => ['Domestic', 'International'])

          Stripe.api_key = @pin_user.stripe_api_secret

          card_token = Stripe::Token.create(
            :card => {
              :number => 5555555555554444,
              :exp_month => 10,
              :exp_year => 2014,
              :cvc => "314"
            }
          )

          params = {}
          params[:transaction] = {}
          params[:transaction][:card_token] = card_token[:id]
          params[:transaction][:buyer_name] = "Tim Gleeson"
          params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
          params[:transaction][:buyer_ip_address] = "101.169.255.252"
          params[:transaction][:shipping_cost] = 0
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.base_cost.should == 10.00
          transaction.shipping_cost_value.should == 10.95
          transaction.shipping_cost_term.should == 'Domestic'
          transaction.transaction_amount.should == 20.95
          transaction.errors.empty?.should == true

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]
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

          Stripe.api_key = @pin_user.stripe_api_secret

          card_token = Stripe::Token.create(
            :card => {
              :number => 5555555555554444,
              :exp_month => 10,
              :exp_year => 2014,
              :cvc => "314"
            }
          )

          params = {}
          params[:transaction] = {}
          params[:transaction][:card_token] = card_token[:id]
          params[:transaction][:buyer_name] = "Tim Gleeson"
          params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
          params[:transaction][:buyer_ip_address] = "101.169.255.252"
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.base_cost.should == 10.00
          transaction.surcharge_cost.should == 1
          transaction.transaction_amount.should == 11
          transaction.errors.empty?.should == true

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]
        end

        it "of $5.95" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_surcharge => true,
                                          :surcharge_value => 5.95,
                                          :surcharge_unit => 'dollar')

          Stripe.api_key = @pin_user.stripe_api_secret

          card_token = Stripe::Token.create(
            :card => {
              :number => 5555555555554444,
              :exp_month => 10,
              :exp_year => 2014,
              :cvc => "314"
            }
          )

          params = {}
          params[:transaction] = {}
          params[:transaction][:card_token] = card_token[:id]
          params[:transaction][:buyer_name] = "Tim Gleeson"
          params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
          params[:transaction][:buyer_ip_address] = "101.169.255.252"
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.base_cost.should == 10.00
          transaction.surcharge_cost.should == 5.95
          transaction.transaction_amount.should == 15.95
          transaction.errors.empty?.should == true

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]
        end
      end
    end
  end

  describe 'using Braintree' do
    before :each do
      @pin_user = FactoryGirl.create(:user,
                                     :email => "tim.j.gleeson+pin@gmail.com",
                                     :payment_method => 'braintree',
                                     :braintree_merchant_key => ENV['BRAINTREE_MERCHANT_ID'],
                                     :braintree_api_key => ENV['BRAINTREE_API_KEY'],
                                     :braintree_api_secret => ENV['BRAINTREE_API_SECRET'],
                                     :braintree_client_side_key => ENV['BRAINTREE_CLIENT_SIDE_KEY'])
    end

    describe "charge $10.00" do
      it "default" do
        @pin_stack = FactoryGirl.create(:stack,
                                        :user_token => @pin_user.id,
                                        :charge_amount => 10)

        params = {}
        params[:name] = "Tim Gleeson"
        params[:number] = "5105105105105100"
        params[:cvv] = "123"
        params[:month] = "12"
        params[:year] = "2015"
        params[:transaction] = {}
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:transaction_amount] = @pin_stack.charge_amount

        transaction = Transaction.new_by_stack(params, @pin_stack)

        transaction.base_cost.should == 10.00
        transaction.transaction_amount.should == 10
        transaction.errors.empty?.should == true

        # charge = Stripe::Charge.retrieve(transaction.charge_token)
        # (transaction.transaction_amount * 100).should == charge[:amount]
      end

      describe "with shipping" do
        it "default" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_shipping => true,
                                          :shipping_cost_value => [10.95, 29.95],
                                          :shipping_cost_term => ['Domestic', 'International'])

          params = {}
          params[:name] = "Tim Gleeson"
          params[:number] = "5105105105105100"
          params[:cvv] = "123"
          params[:month] = "12"
          params[:year] = "2015"
          params[:transaction] = {}
          params[:transaction][:buyer_name] = "Tim Gleeson"
          params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
          params[:transaction][:buyer_ip_address] = "101.169.255.252"
          params[:transaction][:shipping_cost] = 0
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.base_cost.should == 10.00
          transaction.shipping_cost_value.should == 10.95
          transaction.shipping_cost_term.should == 'Domestic'
          transaction.transaction_amount.should == 20.95
          transaction.errors.empty?.should == true

          # charge = Stripe::Charge.retrieve(transaction.charge_token)
          # (transaction.transaction_amount * 100).should == charge[:amount]
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

          params = {}
          params[:name] = "Tim Gleeson"
          params[:number] = "5105105105105100"
          params[:cvv] = "123"
          params[:month] = "12"
          params[:year] = "2015"
          params[:transaction] = {}
          params[:transaction][:buyer_name] = "Tim Gleeson"
          params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
          params[:transaction][:buyer_ip_address] = "101.169.255.252"
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.base_cost.should == 10.00
          transaction.surcharge_cost.should == 1
          transaction.transaction_amount.should == 11
          transaction.errors.empty?.should == true

          # charge = Stripe::Charge.retrieve(transaction.charge_token)
          # (transaction.transaction_amount * 100).should == charge[:amount]
        end

        it "of $5.95" do
          @pin_stack = FactoryGirl.create(:stack,
                                          :user_token => @pin_user.id,
                                          :charge_amount => 10,
                                          :require_surcharge => true,
                                          :surcharge_value => 5.95,
                                          :surcharge_unit => 'dollar')

          params = {}
          params[:name] = "Tim Gleeson"
          params[:number] = "5105105105105100"
          params[:cvv] = "123"
          params[:month] = "12"
          params[:year] = "2015"
          params[:transaction] = {}
          params[:transaction][:buyer_name] = "Tim Gleeson"
          params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
          params[:transaction][:buyer_ip_address] = "101.169.255.252"
          params[:transaction][:transaction_amount] = @pin_stack.charge_amount

          transaction = Transaction.new_by_stack(params, @pin_stack)

          transaction.base_cost.should == 10.00
          transaction.surcharge_cost.should == 5.95
          transaction.transaction_amount.should == 15.95
          transaction.errors.empty?.should == true

          # charge = Stripe::Charge.retrieve(transaction.charge_token)
          # (transaction.transaction_amount * 100).should == charge[:amount]
        end
      end
    end
  end
end
