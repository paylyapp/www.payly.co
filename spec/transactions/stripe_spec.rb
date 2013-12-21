require 'spec_helper'

describe Transaction do
  describe 'using Stripe' do
    before :each do
      @user = FactoryGirl.create(:user, :email => "tim.j.gleeson+stripe@gmail.com", :payment_method => 'stripe', :stripe_api_key => ENV['STRIPE_PUBLISHABLE_KEY'], :stripe_api_secret => ENV['STRIPE_SECRET_KEY'])

      def card_token
        Stripe.api_key = @user.stripe_api_secret

        card_token = Stripe::Token.create(
          :card => {
            :number => 5555555555554444,
            :exp_month => 10,
            :exp_year => 2014,
            :cvc => "314"
          }
        )

        card_token[:id]
      end

      def create_transaction
        params = {}
        params[:transaction] = {}
        params[:transaction][:card_token] = card_token
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:shipping_cost] = 0
        params[:transaction][:transaction_amount] = @stack.charge_amount

        Transaction.new_by_stack(params, @stack)
      end
    end

    describe "charge $10.00" do
      it "default" do
        @stack = FactoryGirl.create(:stack,
                                        :user_token => @user.id,
                                        :charge_amount => 10,
                                        :charge_currency => 'AUD')

        transaction = create_transaction
        transaction.transaction_amount.should == 10
        transaction.errors.empty?.should == true
        transaction.save!

        charge = Stripe::Charge.retrieve(transaction.charge_token)
        (transaction.transaction_amount * 100).should == charge[:amount]

        email = ActionMailer::Base.deliveries.last
        email.should deliver_to("tim.j.gleeson@gmail.com")
        email.should_not have_body_text(/Surcharge/)
      end

      it "with more than 2 decimal places" do
        @stack = FactoryGirl.create(:stack,
                                        :user_token => @user.id,
                                        :charge_amount => 10.058,
                                        :charge_currency => 'AUD')

        transaction = create_transaction
        transaction.transaction_amount.should == 10.058
        transaction.errors.empty?.should == true
        transaction.save!

        charge = Stripe::Charge.retrieve(transaction.charge_token)
        ( (transaction.transaction_amount * 100 ).floor() ).should == charge[:amount]

        email = ActionMailer::Base.deliveries.last
        email.should deliver_to("tim.j.gleeson@gmail.com")
        email.should_not have_body_text(/Surcharge/)
      end

      describe "with a currency" do
        it "of AUD" do
          @stack = FactoryGirl.create(:stack,
                                          :user_token => @user.id,
                                          :charge_amount => 10,
                                          :charge_currency => 'AUD')

          transaction = create_transaction
          transaction.transaction_amount.should == 10
          transaction.errors.empty?.should == true
          transaction.save!

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end

        # it "of USD" do
        #   @stack = FactoryGirl.create(:stack,
        #                                   :user_token => @user.id,
        #                                   :charge_amount => 10,
        #                                   :charge_currency => 'USD')

        #   params = {}
        #   params[:transaction] = {}
        #   params[:transaction][:card_token] = card_token
        #   params[:transaction][:buyer_name] = "Tim Gleeson"
        #   params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        #   params[:transaction][:buyer_ip_address] = "101.169.255.252"
        #   params[:transaction][:transaction_amount] = @stack.charge_amount

        #   transaction = Transaction.new_by_stack(params, @stack)

        #   transaction.transaction_amount.should == 10
        #   transaction.errors.empty?.should == true
        # transaction.save!

        #   charge = Hay::Charges.show(@entity.pin_api_secret, transaction.charge_token)
        #   (transaction.transaction_amount * 100).should == charge[:amount]

        #   email = ActionMailer::Base.deliveries.last
        #   email.should deliver_to("tim.j.gleeson@gmail.com")
        #   email.should_not have_body_text(/Surcharge/)
        # end
      end

      describe "with shipping" do
        it "default" do
          @stack = FactoryGirl.create(:stack,
                                          :user_token => @user.id,
                                          :charge_amount => 10,
                                          :require_shipping => true,
                                          :shipping_cost_value => [10.95, 29.95],
                                          :shipping_cost_term => ['Domestic', 'International'])

          transaction = create_transaction
          transaction.transaction_amount.should == 20.95
          transaction.shipping_cost_value.should == 10.95
          transaction.shipping_cost_term.should == 'Domestic'
          transaction.errors.empty?.should == true
          transaction.save!

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end
      end

      describe "with surcharge" do
        it "of 10%" do
          @stack = FactoryGirl.create(:stack,
                                          :user_token => @user.id,
                                          :charge_amount => 10,
                                          :require_surcharge => true,
                                          :surcharge_value => 10,
                                          :surcharge_unit => 'percentage')

          transaction = create_transaction
          transaction.transaction_amount.should == 11
          transaction.surcharge_cost.should == 1
          transaction.errors.empty?.should == true
          transaction.save!

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end

        it "of $5.95" do
          @stack = FactoryGirl.create(:stack,
                                          :user_token => @user.id,
                                          :charge_amount => 10,
                                          :require_surcharge => true,
                                          :surcharge_value => 5.95,
                                          :surcharge_unit => 'dollar')

          transaction = create_transaction
          transaction.transaction_amount.should == 15.95
          transaction.surcharge_cost.should == 5.95
          transaction.errors.empty?.should == true
          transaction.save!

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end
      end

      describe "sends invoice" do
        it "default" do
          @stack = FactoryGirl.create(:stack,
                                          :user_token => @user.id,
                                          :charge_amount => 10,
                                          :send_invoice_email => true,
                                          :seller_trading_name => 'ABC',
                                          :seller_abn => '123',
                                          :seller_address_line1 => '1 Street',
                                          :seller_address_city => 'City',
                                          :seller_address_postcode => '123',
                                          :seller_address_state => 'ABC',
                                          :seller_address_country => 'AUD')

          transaction = create_transaction
          transaction.transaction_amount.should == 10
          transaction.errors.empty?.should == true
          transaction.save!

          charge = Stripe::Charge.retrieve(transaction.charge_token)
          (transaction.transaction_amount * 100).should == charge[:amount]

          email = ActionMailer::Base.deliveries.last
          email.should deliver_to("tim.j.gleeson@gmail.com")
          email.should_not have_body_text(/Surcharge/)
        end

        describe "with shipping" do
          it "default" do
            @stack = FactoryGirl.create(:stack,
                                            :user_token => @user.id,
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

            transaction = create_transaction
            transaction.transaction_amount.should == 20.95
            transaction.shipping_cost_value.should == 10.95
            transaction.shipping_cost_term.should == 'Domestic'
            transaction.errors.empty?.should == true
            transaction.save!

            charge = Stripe::Charge.retrieve(transaction.charge_token)
            (transaction.transaction_amount * 100).should == charge[:amount]

            email = ActionMailer::Base.deliveries.last
            email.should deliver_to("tim.j.gleeson@gmail.com")
            email.should_not have_body_text(/Surcharge/)
          end
        end

        describe "with surcharge" do
          it "of 10%" do
            @stack = FactoryGirl.create(:stack,
                                            :user_token => @user.id,
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

            transaction = create_transaction
            transaction.transaction_amount.should == 11
            transaction.surcharge_cost.should == 1
            transaction.errors.empty?.should == true
            transaction.save!

            charge = Stripe::Charge.retrieve(transaction.charge_token)
            (transaction.transaction_amount * 100).should == charge[:amount]

            email = ActionMailer::Base.deliveries.last
            email.should deliver_to("tim.j.gleeson@gmail.com")
            email.should have_body_text(/Surcharge/)
          end

          it "of $5.95" do
            @stack = FactoryGirl.create(:stack,
                                            :user_token => @user.id,
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

            transaction = create_transaction
            transaction.transaction_amount.should == 15.95
            transaction.surcharge_cost.should == 5.95
            transaction.errors.empty?.should == true
            transaction.save!

            charge = Stripe::Charge.retrieve(transaction.charge_token)
            (transaction.transaction_amount * 100).should == charge[:amount]

            email = ActionMailer::Base.deliveries.last
            email.should deliver_to("tim.j.gleeson@gmail.com")
            email.should have_body_text(/Surcharge/)
          end
        end
      end
    end
  end
end