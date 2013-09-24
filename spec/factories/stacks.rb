# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stack do |f|
    f.product_name "Testing"
    f.charge_type "fixed"
    f.charge_amount 10.95
  end
end
