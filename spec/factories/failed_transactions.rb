# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :failed_transaction do
    subscription_token "MyString"
    reason "MyText"
    failed_transaction_token "MyString"
  end
end
