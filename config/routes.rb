Haystack::Application.routes.draw do
  get     "faqs"                              => "home#faqs",                     :as => 'faqs'
  get     "terms"                             => "home#terms",                    :as => 'terms'
  get     "privacy"                           => "home#privacy",                  :as => 'privacy'
  get     "signup/thank-you"                  => "home#thank_you",                :as => 'new_user_register_thank_you'
  get     "commitment"                        => "home#commitment",               :as => 'commitment'
  # get     "features"                          => "home#features",                 :as => 'features'
  # get     "press"                             => "home#press",                    :as => 'press'

  get     "pocket"                            => "customer#index",                :as => 'pocket'
  post    "pocket"                            => "customer#create",               :as => 'pocket'
  get     "pocket/transactions"               => "customer#list",                 :as => 'pocket_transactions'
  get     "pocket/transactions/:transaction_token" => "customer#item",            :as => 'pocket_transaction'

  get     "p/*page_token"                     => "transactions#new",      :as => 'page_new_transaction'
  post    "p/*page_token"                     => "transactions#create",   :as => 'page_create_transaction'
  get     "t/*page_token"                     => "transactions#complete", :as => 'page_complete_transaction'
  get     "download"                          => "transactions#download",             :as => 'download'

  get     "dashboard"                         => "user#dashboard",                     :as => 'user_root'
  get     "settings"                          => "user#settings",                      :as => 'user_settings'
  get     "pages"                             => "user#pages",                         :as => 'user_pages'
  get     "purchases"                         => "user#purchases",                     :as => 'user_purchases'

  get     "pages/new"                         => "stacks#new",                :as => 'dashboard_new_stack'
  get     "pages/:stack_token"                => "stacks#settings",                  :as => 'dashboard_stack'
  get     "pages/:stack_token/purchases"      => "stacks#purchases",     :as => 'dashboard_stack_transactions'
  get     "pages/:stack_token/update/buyer/download" => "stacks#updated_download",  :as => 'dashboard_stack_updated_download'

  get     "/purchases/:transaction_token" => "stacks#purchase",      :as => 'dashboard_stack_transaction'

  post    "pages/s_new"                   => "stacks#create",           :as => 'stack_create'
  put     "pages/:stack_token"            => "stacks#update",           :as => 'stack_update'
  delete  "pages/:stack_token/destroy"    => "stacks#destroy",          :as => 'stack_destroy'


  match "dashboard/s_new", :to => redirect {|params,request| "/pages/new"}
  match "dashboard/:stack_token", :to => redirect {|params,request| "/pages/#{params[:stack_token]}"}
  match "dashboard/:stack_token/payments", :to => redirect {|params,request| "/dashboard/#{params[:stack_token]}/purchases"}
  match "dashboard/:stack_token/payments/:transaction_token", :to => redirect {|params,request| "/dashboard/#{params[:stack_token]}/purchases/#{params[:transaction_token]}"}

  match "dashboard/:stack_token/payments", :to => redirect {|params,request| "/pages/#{params[:stack_token]}/purchases"}
  match "dashboard/:stack_token/payments/:transaction_token", :to => redirect {|params,request| "/pages/#{params[:stack_token]}/purchases/#{params[:transaction_token]}"}

  post "api/sessions/create" => "api/sessions#create"
  delete "api/sessions/destroy" => "api/sessions#destroy"

  get "api/pages" => "api/pages#index"
  get "api/pages/:token" => "api/pages#show"

  get "api/purchases/:token" => "api/purchases#show"


  devise_for :users, :controllers => { :registrations => :registrations }, :skip => [:sessions]
  as :user do
    get   'login'                             => 'devise/sessions#new',           :as => :new_user_session
    post  'login'                             => 'devise/sessions#create',        :as => :user_session
    delete'signout'                           => 'devise/sessions#destroy',       :as => :destroy_user_session
    get   "signup"                            => "devise/registrations#new",      :as => :new_user_registration
  end

  root :to => 'home#index'
end
