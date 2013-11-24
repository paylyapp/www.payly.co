# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

unless Rails.env.production?

  time_start = Time.now

  puts 'Deleting previous data'
  Transaction.delete_all
  User.delete_all
  Stack.delete_all
  Entity.delete_all

  puts '--------------------------------'
  puts 'Adding User 1'
  user_1 = User.new
  user_1.full_name = "Tim Gleeson"
  user_1.email = "tim.j.gleeson@gmail.com"
  user_1.username = "timjgleeson"
  user_1.password = "1234abcd"
  user_1.password_confirmation = "1234abcd"
  user_1.tos_agreement = true
  user_1.save!
  user_1.confirm!

  puts '--------------------------------'
  puts 'Update user 1 entity'
  entity = user_1.entity
  entity.payment_method = 'pin_payments'
  entity.pin_api_key = ENV['PIN_PUBLISHABLE_KEY']
  entity.pin_api_secret = ENV['PIN_SECRET_KEY']
  entity.save!

  puts '--------------------------------'

  puts 'Adding First Stack'
  stack_1 = entity.stacks.build
  stack_1.product_name = "Test Product 1"
  stack_1.charge_type = 'fixed'
  stack_1.charge_amount = 1.00
  stack_1.page_token = "test/stack/1"
  stack_1.charge_currency = "AUD"
  stack_1.description = "Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit."
  stack_1.seller_name = "Tim Gleeson"
  stack_1.seller_email = "tim.j.gleeson@gmail.com"
  stack_1.save!

  puts '--------------------------------'
  puts 'Adding Second Stack'
  stack_2 = entity.stacks.build
  stack_2.product_name = "Test Product 2"
  stack_2.charge_type = 'fixed'
  stack_2.charge_amount = 1.00
  stack_2.page_token = "test/stack/2"
  stack_2.charge_currency = "USD"
  stack_2.description = "Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit."
  stack_2.seller_name = "Tim Gleeson"
  stack_2.seller_email = "tim.j.gleeson@gmail.com"
  stack_2.save!

  for i in 1..30
    puts '--------------------------------'
    puts "Number #{i}"
    puts 'Finding stack'

    puts 'Building Transaction'

    if i%2 == 0
      stack = stack_1

      puts 'Simulating Pin.js by creating Card Token'

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
      card_token = Hay::CardToken.create(user_1.entity.pin_api_secret, payload)

      params = {}
      params[:transaction] = {}
      params[:transaction][:card_token] = card_token[:response][:token]
      params[:transaction][:buyer_name] = "Tim Gleeson"
      params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:transaction][:buyer_ip_address] = "101.169.255.252"
      params[:transaction][:transaction_amount] = stack_1.charge_amount

      puts 'Generating Pin Payments Charge Token'
      transaction = Transaction.new_by_stack(params, stack_1)
      transaction.save!

      if i%3 == 0
        transaction.created_at = 1.weeks.ago
      end
      if i%6 == 0
        transaction.created_at = 1.days.ago
      end
      transaction.save!
    else
      stack = stack_2

      puts 'Simulating Pin.js by creating Card Token'

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
      card_token = Hay::CardToken.create(entity.pin_api_secret, payload)

      params = {}
      params[:transaction] = {}
      params[:transaction][:card_token] = card_token[:response][:token]
      params[:transaction][:buyer_name] = "Tim Gleeson"
      params[:transaction][:buyer_email] = "tim.j.gleeson@gmail.com"
      params[:transaction][:buyer_ip_address] = "101.169.255.252"
      params[:transaction][:transaction_amount] = stack_2.charge_amount


      puts 'Generating Pin Payments Charge Token'
      transaction = Transaction.new_by_stack(params, stack_2)
      transaction.save!

      if i%3 == 0
        transaction.created_at = 1.weeks.ago
      end
      if i%6 == 0
        transaction.created_at = 1.days.ago
      end
      transaction.save!
    end
  end

  time_end = Time.now

  puts "Seeding took #{time_end - time_start}"

end