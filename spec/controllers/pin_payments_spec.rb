require 'spec_helper'

describe 'Pin Payments' do
  before :each do
    @valid_credit_card_MC = 5520000000000000
    @failed_credit_card_MC = 5560000000000001
    @valid_credit_card_VISA = 4200000000000000
    @failed_credit_card_VISA = 4100000000000001

    @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
    @pin_stack = FactoryGirl.create(:stack, :user_token => @pin_user.id)

    @pin_user.save!
    @pin_stack.save!
  end

  describe '(valid)' do
    before :each do
      payload = {
        'number' => @valid_credit_card_MC,
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
      @card_token = Hay::CardToken.create(@pin_user.pin_api_secret, payload)
      @card_token = @card_token[:response][:token]
    end

    describe 'as one time transaction' do
      it "can make a valid Pin Payments transaction" do
        params = {}
        params[:transaction] = {}
        params[:transaction][:card_token] = @card_token
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:transaction_amount] = @pin_stack.charge_amount

        transaction = Transaction.new_by_stack(params, @pin_stack)

        transaction.errors.empty?.should == true
        transaction.save!.should == true
      end
    end

    describe 'as subscription' do
      it "can create a subscription with a valid credit card" do
        params = {}
        params[:subscription] = {}
        params[:subscription][:card_token] = @card_token
        params[:subscription][:buyer_name] = "Tim Gleeson"
        params[:subscription][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:subscription][:buyer_ip_address] = "101.169.255.252"
        params[:subscription][:transaction_amount] = @pin_stack.charge_amount

        subscription = Subscription.new_by_stack(params, @pin_stack)

        subscription.errors.empty?.should == true
        subscription.save!.should == true
      end

      it "can update credit card with a valid credit card and can create a transaction" do
        params = {}
        params[:subscription] = {}
        params[:subscription][:card_token] = @card_token
        params[:subscription][:buyer_name] = "Tim Gleeson"
        params[:subscription][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:subscription][:buyer_ip_address] = "101.169.255.252"
        params[:subscription][:transaction_amount] = @pin_stack.charge_amount

        subscription = Subscription.new_by_stack(params, @pin_stack)

        subscription.errors.empty?.should == true
        subscription.save!.should == true

        card_payload = {
          'number' => @valid_credit_card_VISA,
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
        card_token = Hay::CardToken.create(@pin_user.pin_api_secret, card_payload)

        params = {}
        params[:card_token] = card_token[:response][:token]

        subscription.update_customer_information(params)
        subscription.errors.empty?.should == true

        transaction_errors = subscription.new_transaction()
        transaction_errors.blank?.should == true
      end
    end
  end

  describe '(failed)' do
    before :each do
      payload = {
        'number' => @failed_credit_card_MC,
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
      @card_token = Hay::CardToken.create(@pin_user.pin_api_secret, payload)
      @card_token = @card_token[:response][:token]
    end

    describe 'as one time transaction' do
      it "can make an invalid Pin Payments transaction" do
        params = {}
        params[:transaction] = {}
        params[:transaction][:card_token] = @card_token
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:transaction_amount] = @pin_stack.charge_amount

        transaction = Transaction.new_by_stack(params, @pin_stack)
        transaction.errors.empty?.should_not == true
      end
    end

    describe 'as subscription' do
      it "can update credit card with a invalid credit card and can not create a transaction" do
        payload = {
          'number' => @valid_credit_card_MC,
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
        params[:subscription] = {}
        params[:subscription][:card_token] = card_token[:response][:token]
        params[:subscription][:buyer_name] = "Tim Gleeson"
        params[:subscription][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:subscription][:buyer_ip_address] = "101.169.255.252"
        params[:subscription][:transaction_amount] = @pin_stack.charge_amount

        subscription = Subscription.new_by_stack(params, @pin_stack)

        subscription.errors.empty?.should == true
        subscription.save!.should == true

        params = {}
        params[:card_token] = @card_token

        subscription = subscription.update_customer_information(params)
        subscription.errors.empty?.should == true
        subscription.save!.should == true

        expect{ subscription.new_transaction() }.to change(FailedTransaction,:count).by(1) && change(Transaction,:count).by(0)

        failed_transaction = FailedTransaction.find_by_subscription_token(subscription.subscription_token)
        failed_transaction.reason.should == 'The card was declined'
        failed_transaction.subscription_token.should == subscription.subscription_token
      end
    end
  end
end
