require 'spec_helper'

describe Transaction do

  describe 'Pin payments' do
    before :all do
      @pin_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+pin@gmail.com", :payment_method => 'pin_payments', :pin_api_key => ENV['PIN_PUBLISHABLE_KEY'], :pin_api_secret => ENV['PIN_SECRET_KEY'])
      @pin_stack = FactoryGirl.create(:stack, :user_token => @pin_user.id)
    end

    it "can make a valid Pin Payments transaction" do
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
      transaction.errors.empty?.should == true
    end

    it "can make an invalid Pin Payments transaction" do
      payload = {
        'number' => 5560000000000001,
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
      transaction.errors.empty?.should_not == true
    end
  end

  describe 'Stripe' do
    before :all do
      @stripe_user = FactoryGirl.create(:user, :email => "tim.j.gleeson+stripe@gmail.com", :payment_method => 'stripe', :stripe_api_key => ENV['STRIPE_PUBLISHABLE_KEY'], :stripe_api_secret => ENV['STRIPE_SECRET_KEY'])
      @stripe_stack = FactoryGirl.create(:stack, :user_token => @stripe_user.id)
    end

    it "can make a valid Stripe transaction" do
      Stripe.api_key = @stripe_user.stripe_api_secret

      card_token = Stripe::Token.create(
        :card => {
          :number => "4242424242424242",
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
      params[:transaction][:transaction_amount] = @stripe_stack.charge_amount

      transaction = Transaction.new_by_stack(params, @stripe_stack)
      transaction.errors.empty?.should == true
    end

    it "can make an invalid Stripe transaction" do
      Stripe.api_key = @stripe_user.stripe_api_secret

      card_token = Stripe::Token.create(
        :card => {
          :number => "4000000000000002",
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
      params[:transaction][:transaction_amount] = @stripe_stack.charge_amount

      transaction = Transaction.new_by_stack(params, @stripe_stack)
      transaction.errors.empty?.should_not == true
    end
  end

  # it "can make a valid Braintree transaction" do

  #   card_token = Stripe::Token.create(
  #     :card => {
  #       :number => "4242424242424242",
  #       :exp_month => 10,
  #       :exp_year => 2014,
  #       :cvc => "314"
  #     }
  #   )

  #   params = {}
  #   params[:transaction] = {}
  #   params[:transaction][:card_token] = card_token[:id]
  #   params[:transaction][:buyer_name] = "Tim Gleeson"
  #   params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
  #   params[:transaction][:buyer_ip_address] = "101.169.255.252"
  #   params[:transaction][:transaction_amount] = @stripe_stack.charge_amount

  #   transaction = Transaction.new_by_stack(params, @stripe_stack)
  #   transaction.errors.empty?.should == true
  # end
end
