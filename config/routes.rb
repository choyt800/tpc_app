Rails.application.routes.draw do
  devise_for :admins, skip: :registerable
  resources :mailboxes
  resources :keycard_checkouts, only: [:index]
  resources :mail_services, only: [:index]
  resources :memberships, only: [:index]
  resources :custom_subscriptions
  resources :members do
    resources :memberships, except: [:index]
    resources :custom_subscriptions
    delete 'memberships/:id/cancel' => 'memberships#cancel', as: 'cancel_membership'
    resources :keycard_checkouts, except: [:index]
    delete 'keycard_checkouts/:id/cancel' => 'keycard_checkouts#cancel', as: 'cancel_keycard_checkout'
    resources :mail_services, except: [:index]
    delete 'mail_services/:id/cancel' => 'mail_services#cancel', as: 'cancel_mail_service'
    post 'create_stripe' => 'members#create_stripe'
    post 'link_stripe' => 'members#link_stripe'
    post 'update_stripe' => 'members#update_stripe'
  end
  resources :teams do
    resources :memberships, except: [:index]
    resources :custom_subscriptions
    resources :members, except: [:index]
    delete 'memberships/:id/cancel' => 'memberships#cancel', as: 'cancel_membership'
    resources :keycard_checkouts, except: [:index]
    delete 'keycard_checkouts/:id/cancel' => 'keycard_checkouts#cancel', as: 'cancel_keycard_checkout'
    resources :mail_services, except: [:index]
    delete 'mail_services/:id/cancel' => 'mail_services#cancel', as: 'cancel_mail_service'
    post 'create_stripe' => 'teams#create_stripe'
    post 'link_stripe' => 'teams#link_stripe'
    post 'update_stripe' => 'teams#update_stripe'
  end
  resources :keycards
  resources :charges
  resources :checkins
  put 'plans/change_order' => 'plans#change_order'
  resources :plans
  resources :admins, except: [:new, :create, :show]
  get '/inactive' => 'members#inactive'
  get '/counts' => 'members#counts'
  post '/stripe' => 'stripe#webhook'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'high_voltage/pages#show', id: 'management'

  # config/initializers/high_voltage.rb
  HighVoltage.configure do |config|
    config.route_drawer = HighVoltage::RouteDrawers::Root
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end


end
