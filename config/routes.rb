Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  put 'actuator/resources/:uuid/exec/:capability', to: 'actuator#exec'
  get 'actuator/resources/:uuid/status/:capability', to: 'actuator#status'

  post 'resources', to: 'actuator#create'
  put 'resources', to: 'actuator#update'

end
