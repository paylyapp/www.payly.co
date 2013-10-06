ruby '1.9.3'
source 'https://rubygems.org'

gem 'rails', '3.2.14'

gem 'thin'
gem 'unicorn'

gem 'capistrano'
gem 'rvm-capistrano'

gem 'attr_encrypted'
gem 'heroku'
gem 'rails_12factor'
gem 'rest-client', '~> 1.4'
gem 'multi_json', '>= 1.0.4', '< 2'

gem 'hay', :git => 'git://github.com/paylyapp/hay.git'
gem 'braintree'
gem 'stripe'

gem 'impressionist'

gem 'pg'
gem 'postgres_ext'

gem 'devise'
gem 'gravtastic'

gem 'aws-sdk'
gem 'paperclip'
gem 'fog'

gem 'countries'
gem 'country_select'

gem 'will_paginate', '~> 3.0'

gem 'google-analytics-rails'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass-rails'
  gem 'sass-mediaqueries-rails'
  gem 'font-awesome-sass-rails'

  gem 'jquery-rails'
  gem 'modernizr-rails'

  gem 'uglifier', '>= 1.0.3'

  gem 'turbo-sprockets-rails3'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.0'
  gem 'factory_girl_rails'
  gem 'shoulda'
  gem 'nokogiri'
  gem 'dotenv-rails'
end

group :development do
  gem 'taps'
  gem 'sqlite3'

  gem 'better_errors'
  gem 'rails_best_practices'
  gem 'brakeman', :require => false
  gem 'quiet_assets'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'database_cleaner'
end
