Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  put 'resources/actuate', to: 'actuator#actuate'
  get 'resources/:uuid/:capability', to: 'actuator#cap_status'
end
