Haystack::Application.routes.draw do

  # Marketing

  get     "faqs"                              => "home#faqs",                     :as => 'faqs'
  get     "terms"                             => "home#terms",                    :as => 'terms'
  get     "privacy"                           => "home#privacy",                  :as => 'privacy'
  get     "signup/thank-you"                  => "home#thank_you",                :as => 'new_user_register_thank_you'
  get     "commitment"                        => "home#commitment",               :as => 'commitment'
  # get     "features"                          => "home#features",                 :as => 'features'
  # get     "press"                             => "home#press",                    :as => 'press'


  # Pocket

  get     "pocket"                            => "customer#index",                :as => 'pocket'
  post    "pocket"                            => "customer#create",               :as => 'pocket'
  get     "pocket/transactions"               => "customer#list",                 :as => 'pocket_transactions'
  get     "pocket/transactions/:transaction_token" => "customer#show",            :as => 'pocket_transaction'
  get     "pocket/subscriptions"               => "customer#subscriptions",       :as => 'pocket_subscriptions'
  get     "pocket/subscriptions/:subscription_token" => "customer#subscription",  :as => 'pocket_subscription'
  get     "pocket/subscriptions/:subscription_token/edit" => "customer#subscription_edit",:as => 'pocket_subscription_edit'

  put     "pocket/subscriptions/:subscription_token" => "customer#subscription_update",  :as => 'pocket_subscription'
  delete  "pocket/subscriptions/:subscription_token" => "customer#subscription_destroy",  :as => 'pocket_subscription'


  # Payment Pages

  get     "p/*page_token"                     => "transactions#new",              :as => 'page_new_transaction'
  post    "p/*page_token"                     => "transactions#create",           :as => 'page_create_transaction'
  get     "pt/*page_token"                    => "transactions#complete",         :as => 'page_complete_transaction'
  get     "download"                          => "transactions#download",         :as => 'download'


  # Subscription Pages

  get     "s/*page_token"                     => "subscription#new",              :as => 'new_subscription'
  post    "s/*page_token"                     => "subscription#create",           :as => 'create_subscription'
  get     "st/*page_token"                    => "subscription#complete",         :as => 'complete_subscription'


  # Users

  devise_for :users, :controllers => { :registrations => :registrations }, :skip => [:sessions]

  as :user do
    get   'login'                             => 'devise/sessions#new',           :as => :new_user_session
    post  'login'                             => 'devise/sessions#create',        :as => :user_session
    delete'signout'                           => 'devise/sessions#destroy',       :as => :destroy_user_session
    get   "signup"                            => "devise/registrations#new",      :as => :new_user_registration
  end


  # Dashboard

  get     "dashboard"                         => "user#dashboard",                :as => 'user_root'
  get     "settings"                          => "user#settings",                 :as => 'user_settings'

  get     "pages"                             => "user#pages",                    :as => 'user_pages'
  get     "pages/new"                         => "stacks#new",                    :as => 'dashboard_new_stack'
  get     "pages/new/one-time"                => "stacks#new_one_time",           :as => 'dashboard_new_one_time'
  get     "pages/new/digital-download"        => "stacks#new_digital_download",   :as => 'dashboard_new_digital_download'
  get     "pages/new/subscription"            => "stacks#new_subscription",       :as => 'dashboard_new_subscription'
  post    "pages/new/one-time"                => "stacks#create_one_time",        :as => 'stack_create_one_time'
  post    "pages/new/digital-download"        => "stacks#create_digital_download",:as => 'stack_create_digital_download'
  post    "pages/new/subscription"            => "stacks#create_subscription",    :as => 'stack_create_subscription'

  get     "pages/:stack_token"                => "stacks#settings",               :as => 'dashboard_stack'
  get     "pages/:stack_token/purchases"      => "stacks#purchases",              :as => 'dashboard_stack_transactions'
  get     "pages/:stack_token/subscriptions"  => "stacks#subscriptions",          :as => 'dashboard_stack_subscriptions'
  put     "pages/:stack_token"                => "stacks#update",                 :as => 'stack_update'
  delete  "pages/:stack_token/delete"         => "stacks#destroy",                :as => 'stack_destroy'
  get     "pages/:stack_token/update/buyer/download" => "stacks#updated_download",:as => 'dashboard_stack_updated_download'

  get     "purchases"                         => "user#purchases",                :as => 'user_purchases'
  get     "purchases/:transaction_token"      => "stacks#purchase",               :as => 'dashboard_stack_transaction'

  get     "subscriptions"                     => "user#subscriptions",            :as => 'user_subscriptions'
  get     "subscriptions/:subscription_token" => "stacks#subscription",           :as => 'dashboard_stack_subscription'

  put     "subscriptions/:subscription_token/edit" => "stacks#subscription",      :as => 'dashboard_stack_subscription'
  delete  "subscriptions/:subscription_token" => "stacks#subscription_destroy",   :as => 'dashboard_stack_subscription'


  # API

  post "api/sessions/create" => "api/sessions#create"
  delete "api/sessions/destroy" => "api/sessions#destroy"

  get "api/pages" => "api/pages#index"
  get "api/pages/:token" => "api/pages#show"

  get "api/purchases/:token" => "api/purchases#show"


  # 301 redirects

  match "dashboard/s_new", :to => redirect {|params,request| "/pages/new"}
  match "dashboard/:stack_token", :to => redirect {|params,request| "/pages/#{params[:stack_token]}"}
  match "dashboard/:stack_token/payments", :to => redirect {|params,request| "/dashboard/#{params[:stack_token]}/purchases"}
  match "dashboard/:stack_token/payments/:transaction_token", :to => redirect {|params,request| "/dashboard/#{params[:stack_token]}/purchases/#{params[:transaction_token]}"}

  match "dashboard/:stack_token/payments", :to => redirect {|params,request| "/pages/#{params[:stack_token]}/purchases"}
  match "dashboard/:stack_token/payments/:transaction_token", :to => redirect {|params,request| "/pages/#{params[:stack_token]}/purchases/#{params[:transaction_token]}"}


  # Root

  root :to => 'home#index'
end
