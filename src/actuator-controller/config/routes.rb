Rails.application.routes.draw do
  Healthcheck.routes(self)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'health_check', to: 'health_check#index'
  post '/commands', to: 'actuator#create'
  get '/commands', to: 'actuator#index'
end
