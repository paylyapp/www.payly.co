# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do |f|
    f.buyer_email "test@example.org"
    f.buyer_name "Tim Gleeson"
    f.transaction_amount 10.95
  end
end
