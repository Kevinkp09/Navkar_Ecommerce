Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      resources :products do
        post :add_images
        delete :delete_image, on: :member
      end
      resources :users do
        get :credential, on: :collection
        post :login, on: :collection
      end
      resources :categories
      resources :couriers
      resources :carts, only: [:index] do
        post :apply_coupon, on: :collection
      end
      resources :cart_items, only: [:create, :destroy, :update]
      resources :coupons
      resources :orders, only: [:create, :index] do
        post :payment_callback, on: :collection
        patch :update_status
        put :assign_courier
      end
      resources :quotations, only: [:create, :index, :destroy, :update] do
        post :send_quotation_details
      end
      resources :testimonials
      resources :pages, only: [:index] do
        post :add_images, on: :member
        post :add_logos, on: :member
        delete 'destroy_image/:image_id', to: 'pages#destroy_image', on: :collection
      end
    end
  end
end
