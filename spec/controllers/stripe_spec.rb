require 'spec_helper'

describe 'Stripe' do
  before :each do
    @valid_credit_card_MC = 5555555555554444
    # @failed_credit_card_MC = 5560000000000001
    @valid_credit_card_VISA = 4242424242424242
    @failed_credit_card_VISA = 4000000000000002

    @stripe_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+stripe@gmail.com", :payment_method => 'stripe', :stripe_api_key => ENV['STRIPE_PUBLISHABLE_KEY'], :stripe_api_secret => ENV['STRIPE_SECRET_KEY'])
    @stripe_stack = FactoryGirl.create(:stack, :user_token => @stripe_user.id)

    @stripe_user.save!
    @stripe_stack.save!
  end

  describe '(valid)' do
    before :each do
      Stripe.api_key = @stripe_user.stripe_api_secret

      card_token = Stripe::Token.create(
        :card => {
          :number => @valid_credit_card_VISA,
          :exp_month => 10,
          :exp_year => 2014,
          :cvc => "314"
        }
      )

      @card_token = card_token[:id]
    end

    describe 'as one time transaction' do
      it "can make a valid transaction" do
        params = {}
        params[:transaction] = {}
        params[:transaction][:card_token] = @card_token
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:transaction_amount] = @stripe_stack.charge_amount

        transaction = Transaction.new_by_stack(params, @stripe_stack)

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
        params[:subscription][:transaction_amount] = @stripe_stack.charge_amount

        subscription = Subscription.new_by_stack(params, @stripe_stack)

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
        params[:subscription][:transaction_amount] = @stripe_stack.charge_amount

        subscription = Subscription.new_by_stack(params, @stripe_stack)

        subscription.errors.empty?.should == true
        subscription.save!.should == true

        card_token = Stripe::Token.create(
          :card => {
            :number => @valid_credit_card_MC,
            :exp_month => 10,
            :exp_year => 2014,
            :cvc => "314"
          }
        )

        @card_token = card_token[:id]

        params = {}
        params[:card_token] = @card_token

        subscription.update_customer_information(params)
        subscription.errors.empty?.should == true

        transaction_errors = subscription.new_transaction()
        transaction_errors.blank?.should == true
      end
    end
  end

  describe '(failed)' do
    before :each do
      Stripe.api_key = @stripe_user.stripe_api_secret

      card_token = Stripe::Token.create(
        :card => {
          :number => @failed_credit_card_VISA,
          :exp_month => 10,
          :exp_year => 2014,
          :cvc => "314"
        }
      )

      @card_token = card_token[:id]
    end

    describe 'as one time transaction' do
      it "can make an invalid transaction" do
        params = {}
        params[:transaction] = {}
        params[:transaction][:card_token] = @card_token
        params[:transaction][:buyer_name] = "Tim Gleeson"
        params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:transaction][:buyer_ip_address] = "101.169.255.252"
        params[:transaction][:transaction_amount] = @stripe_stack.charge_amount

        transaction = Transaction.new_by_stack(params, @stripe_stack)
        transaction.errors.empty?.should_not == true
      end
    end

    describe 'as subscription' do
      it "can update credit card with a invalid credit card and can not create a transaction" do
        # Updating a credit card on a customer,
        # Stripe will automatically validate the card

        card_token = Stripe::Token.create(
          :card => {
            :number => @valid_credit_card_VISA,
            :exp_month => 10,
            :exp_year => 2014,
            :cvc => "314"
          }
        )

        _card_token = card_token[:id]

        params = {}
        params[:subscription] = {}
        params[:subscription][:card_token] = _card_token
        params[:subscription][:buyer_name] = "Tim Gleeson"
        params[:subscription][:buyer_email] = "tim.j.gleeson@gmail.com"
        params[:subscription][:buyer_ip_address] = "101.169.255.252"
        params[:subscription][:transaction_amount] = @stripe_stack.charge_amount

        subscription = Subscription.new_by_stack(params, @stripe_stack)

        subscription.errors.empty?.should == true
        subscription.save!.should == true

        params = {}
        params[:card_token] = @card_token

        subscription = subscription.update_customer_information(params)
        subscription.errors.empty?.should_not == true

        # expect{ subscription.new_transaction() }.to change(FailedTransaction,:count).by(1) && change(Transaction,:count).by(0)

        # failed_transaction = FailedTransaction.find_by_subscription_token(subscription.subscription_token)
        # failed_transaction.reason.should == 'Your card was declined.'
        # failed_transaction.subscription_token.should == subscription.subscription_token
      end
    end
  end
end
