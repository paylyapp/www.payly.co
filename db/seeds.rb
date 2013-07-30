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

  puts '--------------------------------'
  puts 'Adding User'
  user = User.new
  user.full_name = "Tim Gleeson"
  user.email = "tim.j.gleeson@gmail.com"
  user.password = "1234abcd"
  user.password_confirmation = "1234abcd"
  user.tos_agreement = true
  user.pin_api_key = ENV['PIN_PUBLISHABLE_KEY']
  user.pin_api_secret = ENV['PIN_SECRET_KEY']
  user.save!
  user.confirm!

  puts '--------------------------------'
  user = User.first()
  puts 'Pin API Key: ' + user.pin_api_key
  puts 'Pin API Secret: ' + user.pin_api_secret

  puts '--------------------------------'
  puts 'Adding First Stack'
  stack_1 = user.stacks.build
  stack_1.product_name = "Test Product 1"
  stack_1.charge_amount = 1.00
  stack_1.charge_currency = "AUD"
  stack_1.description = "Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit."
  stack_1.primary_image = File.new("test/fixtures/test-image.jpg")
  stack_1.seller_name = "Tim Gleeson"
  stack_1.seller_email = "tim.j.gleeson@gmail.com"
  stack_1.save!

  puts '--------------------------------'
  puts 'Adding Second Stack'
  stack_2 = user.stacks.build
  stack_2.product_name = "Test Product 2"
  stack_2.charge_amount = 1.00
  stack_2.charge_currency = "AUD"
  stack_2.description = "Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit."
  stack_2.primary_image = File.new("test/fixtures/test-image.jpg")
  stack_2.seller_name = "Tim Gleeson"
  stack_2.seller_email = "tim.j.gleeson@gmail.com"
  stack_2.save!

  # for i in 1..40
  #   puts '--------------------------------'
  #   puts "Number #{i}"
  #   puts 'Finding stack'

  #   if i%2 == 0
  #     stack = stack_1
  #   else
  #     stack = stack_2
  #   end

  #   puts 'Creating card token'
  #   payload = {
  #     'number' => 5520000000000000,
  #     'expiry_month' => 05,
  #     'expiry_year' => 2020,
  #     'cvc' => 123,
  #     'name' => 'Tim Gleeson',
  #     'address_line1' => '7 Braeside Crescent',
  #     'address_line2' => '',
  #     'address_city' => 'Glen Alpine',
  #     'address_postcode' => 2560,
  #     'address_state' => 'NSW',
  #     'address_country' => 'Australia'
  #   }
  #   card_token = Hay::CardToken.create(user.pin_api_secret, payload)

  #   puts 'Building Transaction'
  #   transaction = stack.transactions.build
  #   transaction.card_token = card_token[:response][:token]
  #   transaction.buyer_name = "Tim Gleeson"
  #   transaction.buyer_email = "tim.j.gleeson@gmail.com"
  #   transaction.buyer_ip_address = "101.169.255.252"
  #   transaction.transaction_amount = 12.00

  #   if i%3 == 0
  #     transaction.created_at = 2.weeks.ago
  #   end
  #   if i%6 == 0
  #     transaction.created_at = 2.months.ago
  #   end

  #   puts 'Generating Pin Payments Charge Token'
  #   transaction.save!
  # end

  time_end = Time.now

  puts "Seeding took #{time_end - time_start}"

end