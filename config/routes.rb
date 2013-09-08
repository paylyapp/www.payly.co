Haystack::Application.routes.draw do
  get     "faqs"                              => "home#faqs",                     :as => 'faqs'
  get     "terms"                             => "home#terms",                    :as => 'terms'
  get     "privacy"                           => "home#privacy",                  :as => 'privacy'
  get     "signup/thank-you"                  => "home#thank_you",                :as => 'new_user_register_thank_you'
  # get     "features"                          => "home#features",                 :as => 'features'
  # get     "press"                             => "home#press",                    :as => 'press'

  post     "test_url_for_webhook"             => "test#testing"

  get     "pocket"                            => "customer#index",                :as => 'pocket'
  post    "pocket"                            => "customer#create",               :as => 'pocket'
  get     "pocket/transactions"               => "customer#list",                 :as => 'pocket_transactions'
  get     "pocket/transactions/:transaction_token" => "customer#item",            :as => 'pocket_transaction'

  get     "l/:username"                       => "transactions#stack_list",           :as => 'transaction_stack_list'
  get     "p/*page_token"                     => "transactions#new_transaction",      :as => 'page_new_transaction'
  post    "p/*page_token"                     => "transactions#create_transaction",   :as => 'page_create_transaction'
  get     "t/*page_token"                     => "transactions#complete_transaction", :as => 'page_complete_transaction'
  get     "download"                          => "transactions#download",             :as => 'download'

  get     "dashboard"                         => "user#root",                     :as => 'user_root'
  get     "settings"                          => "user#settings",                 :as => 'user_settings'

  get     "dashboard/s_new"                   => "stacks#new_stack",              :as => 'dashboard_new_stack'
  get     "dashboard/:stack_token"            => "stacks#stack",                  :as => 'dashboard_stack'
  get     "dashboard/:stack_token/purchases"   => "stacks#stack_transactions",     :as => 'dashboard_stack_transactions'
  get     "dashboard/:stack_token/purchases/:transaction_token" => "stacks#stack_transaction",  :as => 'dashboard_stack_transaction'
  get     "dashboard/:stack_token/update/buyers/download" => "stacks#stack_updated_download",  :as => 'dashboard_stack_updated_download'
  post    "dashboard/s_new"                   => "stacks#create_stack",           :as => 'stack_create'
  put     "dashboard/:stack_token"            => "stacks#update_stack",           :as => 'stack_update'
  delete  "dashboard/:stack_token/destroy"    => "stacks#destroy_stack",          :as => 'stack_destroy'

  match "dashboard/:stack_token/payments", :to => redirect {|params,request| "/dashboard/#{params[:stack_token]}/purchases"}
  match "dashboard/:stack_token/payments/:transaction_token", :to => redirect {|params,request| "/dashboard/#{params[:stack_token]}/purchases/#{params[:transaction_token]}"}

  devise_for :users, :controllers => { :registrations => :registrations }, :skip => [:sessions]
  as :user do
    get   'login'                             => 'devise/sessions#new',           :as => :new_user_session
    post  'login'                             => 'devise/sessions#create',        :as => :user_session
    delete'signout'                           => 'devise/sessions#destroy',       :as => :destroy_user_session
    get   "signup"                            => "devise/registrations#new",      :as => :new_user_registration
  end

  root :to => 'home#index'
end
