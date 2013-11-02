require 'spec_helper'

describe Subscription do
  it "should have relationship" do
    should belong_to(:stack)
    should have_many(:transactions)
  end

  describe "decommissioning" do

    before :each do
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
      @pin_stack = FactoryGirl.create(:stack, :user_token => @pin_user.id)

      @pin_user.save!
      @pin_stack.save!

      @valid_credit_card_MC = 5520000000000000
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
    end

    it "a subscription" do
      params = {}
      params[:subscription] = {}
      params[:subscription][:card_token] = @card_token[:response][:token]
      params[:subscription][:buyer_name] = "Tim Gleeson"
      params[:subscription][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:subscription][:buyer_ip_address] = "101.169.255.252"
      params[:subscription][:transaction_amount] = @pin_stack.charge_amount

      subscription = Subscription.new_by_stack(params, @pin_stack)

      subscription.errors.empty?.should == true
      subscription.save!.should == true

      subscription.decommission

      _subscription = Subscription.find_by_subscription_token(subscription.subscription_token)
      _subscription.nil?.should == true
    end

    it "a stack" do
      params = {}
      params[:subscription] = {}
      params[:subscription][:card_token] = @card_token[:response][:token]
      params[:subscription][:buyer_name] = "Tim Gleeson"
      params[:subscription][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:subscription][:buyer_ip_address] = "101.169.255.252"
      params[:subscription][:transaction_amount] = @pin_stack.charge_amount

      subscription = Subscription.new_by_stack(params, @pin_stack)

      subscription.errors.empty?.should == true
      subscription.save!.should == true

      subscription.stack.decommission

      _subscription = Subscription.find_by_subscription_token(subscription.subscription_token)
      _subscription.nil?.should == true
    end



  end
end
