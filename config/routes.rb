Haystack::Application.routes.draw do
  get     "faqs"                              => "home#faqs",                     :as => 'faqs'
  get     "terms"                             => "home#terms",                    :as => 'terms'
  get     "privacy"                           => "home#privacy",                  :as => 'privacy'
  get     "signup/thank-you"                  => "home#thank_you",                :as => 'new_user_register_thank_you'

  get     "pocket"                            => "customer#index",                :as => 'pocket'
  post    "pocket"                            => "customer#create",               :as => 'pocket'
  get     "pocket/transactions"               => "customer#list",                 :as => 'pocket_transactions'
  get     "pocket/transactions/:transaction_token" => "customer#item",            :as => 'pocket_transaction'

  get     "dashboard"                         => "dashboard#index",               :as => 'user_root'

  get     "dashboard/s_new"                   => "dashboard#new_stack",           :as => 'dashboard_new_stack'
  get     "dashboard/:stack_token"            => "dashboard#stack",               :as => 'dashboard_stack'
  get     "dashboard/:stack_token/payments"   => "dashboard#stack_transactions",  :as => 'dashboard_stack_transactions'
  get     "dashboard/:stack_token/payments/:transaction_token" => "dashboard#stack_transaction",  :as => 'dashboard_stack_transaction'
  get     "dashboard/:stack_token/update/buyers/download" => "dashboard#stack_updated_download", :as => 'dashboard_stack_updated_download'
  post    "dashboard/s_new"                   => "dashboard#create_stack",        :as => 'stack_create'
  put     "dashboard/:stack_token"            => "dashboard#update_stack",        :as => 'stack_update'
  delete  "dashboard/:stack_token/destroy"    => "dashboard#destroy_stack",       :as => 'stack_destroy'

  get     "p/:page_token"                     => "page#new_transaction",          :as => 'page_new_transaction'
  post    "p/:page_token"                     => "page#create_transaction",       :as => 'page_create_transaction'
  get     "p/:page_token/thanks"           => "page#complete_transaction",     :as => 'page_complete_transaction'

  get     "download"                          => "stacks#download",     :as => 'download'

  get     "settings"                          => "user#settings",                 :as => 'user_settings'

  devise_for :users, :controllers => { :registrations => :registrations }, :skip => [:sessions]

  as :user do
    get   'login'                            => 'devise/sessions#new',           :as => :new_user_session
    post  'login'                            => 'devise/sessions#create',        :as => :user_session
    delete'signout'                           => 'devise/sessions#destroy',       :as => :destroy_user_session
    get   "signup"                            => "devise/registrations#new",      :as => :new_user_registration
  end

  root :to => 'home#index'

end
