require 'factory_girl'

FactoryGirl.define do
  factory :user do
    full_name "Tim Gleeson"
    email "tim@payly.co"
    password "testpassword"
    password_confirmation "testpassword"
  end
end