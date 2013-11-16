# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entity do
    entity_name "Tim Gleeson"
    full_name "Tim Gleeson"
    email "tim.j.gleeson@gmail.com"
    currency "AUD"
    user_token "1"
  end
end
