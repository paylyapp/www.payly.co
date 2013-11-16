Haystack::Application.routes.draw do
  get     "faqs"                              => "home#faqs",                       :as => :faqs
  get     "terms"                             => "home#terms",                      :as => :terms
  get     "privacy"                           => "home#privacy",                    :as => :privacy
  get     "signup/thank-you"                  => "home#thank_you",                  :as => :new_user_register_thank_you
  get     "commitment"                        => "home#commitment",                 :as => :commitment
  # get     "features"                          => "home#features",                 :as => :features
  # get     "press"                             => "home#press",                    :as => :press

  get     "pocket"                            => "customer#index",                  :as => :pocket
  post    "pocket"                            => "customer#create",                 :as => :pocket
  get     "pocket/transactions"               => "customer#list",                   :as => :pocket_transactions
  get     "pocket/transactions/:transaction_token" => "customer#show",              :as => :pocket_transaction

  get     "p/*page_token"                     => "transactions#new",                :as => :page_new_transaction
  post    "p/*page_token"                     => "transactions#create",             :as => :page_create_transaction
  get     "t/*page_token"                     => "transactions#complete",           :as => :page_complete_transaction
  get     "download"                          => "transactions#download",           :as => :download


  # USER

  devise_for :users, :controllers => { :registrations => :registrations }, :skip => [:sessions]
  as :user do
    get   'login'                             => 'devise/sessions#new',             :as => :new_user_session
    post  'login'                             => 'devise/sessions#create',          :as => :user_session
    delete'signout'                           => 'devise/sessions#destroy',         :as => :destroy_user_session
    get   "signup"                            => "devise/registrations#new",        :as => :new_user_registration
  end


  # ENTITY

  get     "organisation/new"                   => "entity#new",                     :as => :new_entity
  get     "organisation/:entity_token"         => "entity#show",                    :as => :show_entity
  get     "organisation/:entity_token/profile" => "entity#edit",                    :as => :edit_entity
  post    "organisation"                       => "entity#create",                  :as => :entity
  put     "organisation"                       => "entity#update",                  :as => :entity
  delete  "organisation"                       => "entity#destroy",                 :as => :entity

  get     "organisation/:entity_token/pages/new" => "stacks#new",                   :as => :entity_new_stack
  get     "organisation/:entity_token/pages/new/one-time" => "stacks#one_time",     :as => :entity_new_one_time
  get     "organisation/:entity_token/pages/new/digital-download" => "stacks#digital_download", :as => :entity_new_digital_download

  get     "dashboard"                         => "entity/user#dashboard",                  :as => :user_root
  get     "settings"                          => "entity/user#settings",                   :as => :user_settings
  get     "profile"                           => "entity/user#profile",                    :as => :user_profile
  get     "payment_provider"                  => "entity/user#payment_provider",           :as => :user_payment_provider

  put     "entity/:entity_token/profile"                           => "entity/user#update_profile",             :as => :update_user_profile
  put     "entity/:entity_token/payment_provider"                  => "entity/user#update_payment_provider",    :as => :update_user_payment_provider


  # PAGES

  get     "pages"                             => "entity/pages#index",                     :as => :pages
  get     "pages/new"                         => "entity/pages#new",                       :as => :new_page
  get     "pages/new/one-time"                => "entity/pages#new_one_time",              :as => :new_one_time_page
  get     "pages/new/digital-download"        => "entity/pages#new_digital_download",      :as => :new_digital_download_page

  get     "pages/:stack_token"                => "entity/pages#edit",                      :as => :edit_page
  get     "pages/:stack_token/purchases"      => "entity/pages#show",                      :as => :page

  get     "pages/:stack_token/update/buyer/download" => "entity/pages#updated_download",   :as => :dashboard_stack_updated_download

  post    "entity/:entity_token/pages/new/one-time"         => "entity/pages#create_one_time",         :as => :create_one_time_page
  post    "entity/:entity_token/pages/new/digital-download" => "entity/pages#create_digital_download", :as => :create_digital_download_page
  put     "entity/:entity_token/pages/:stack_token"         => "entity/pages#update",                  :as => :update_page
  delete  "entity/:entity_token/pages/:stack_token/destroy" => "entity/pages#destroy",                 :as => :destroy_page


  # PURCHASES

  get     "purchases"                         => "entity/purchases#index",                :as => :purchases
  get     "purchases/:transaction_token"      => "entity/purchases#show",                 :as => :purchase


  # API

  post "api/sessions/create" => "api/sessions#create"
  delete "api/sessions/destroy" => "api/sessions#destroy"

  get "api/pages" => "api/pages#index"
  get "api/pages/:token" => "api/pages#show"

  get "api/purchases/:token" => "api/purchases#show"

  root :to => 'home#index'
end
