require 'factory_girl'

FactoryGirl.define do
  factory :user do
    full_name "Tim Gleeson"
    email "tim@payly.co"
    username "timjgleeson"
    password "testpassword"
    password_confirmation "testpassword"
    tos_agreement true
  end
end