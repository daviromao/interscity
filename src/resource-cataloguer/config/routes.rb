Rails.application.routes.draw do
  Healthcheck.routes(self)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'resources', to: 'basic_resources#create'
  get 'resources', to: 'basic_resources#index'
  get 'resources/sensors', to: 'basic_resources#index_sensors'
  get 'resources/actuators', to: 'basic_resources#index_actuators'
  get 'resources/search', to: 'basic_resources#search'
  get 'resources/:uuid', to: 'basic_resources#show', as: :basic_resource
  put 'resources/:uuid', to: 'basic_resources#update'
  patch 'capabilities/:name', to: 'capabilities#update'
  put 'capabilities/:name', to: 'capabilities#update'
  post 'capabilities', to: 'capabilities#create'
  get 'capabilities', to: 'capabilities#index'
  get 'capabilities/:name', to: 'capabilities#show'
  delete 'capabilities/:name', to: 'capabilities#destroy'
end
