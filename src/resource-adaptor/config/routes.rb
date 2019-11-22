require 'sidekiq/web'

Rails.application.routes.draw do
  Healthcheck.routes(self)

  mount Sidekiq::Web => '/sidekiq'

  resources :components, except: [:new, :edit] do
    member do
      post 'data/:capability', to: "components#data_specific"
      post 'data', to: "components#data"
      put 'actuate/:capability', to: "components#actuate"
    end
  end

  resources :resources, except: [:new, :edit], controller: :components do
    member do
      post 'data/:capability', to: "components#data_specific"
      post 'data', to: "components#data"
      put 'actuate/:capability', to: "components#actuate"
    end
  end

  get 'subscriptions/', to: "actuators#index"
  get 'subscriptions/:id', to: "actuators#show"
  post 'subscriptions', to: "actuators#subscribe"
  put 'subscriptions/:id', to: "actuators#update"
  delete 'subscriptions/:id', to: "actuators#destroy"
end
