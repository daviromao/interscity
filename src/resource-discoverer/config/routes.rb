Rails.application.routes.draw do
  Healthcheck.routes(self)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'resources', to: 'discovery#resources'
end
