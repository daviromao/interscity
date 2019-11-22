# frozen_string_literal: true

Rails.application.routes.draw do
  Healthcheck.routes(self)

  scope 'resources', via: [:post, :get], defaults: { format: :json } do
    match 'data', as: 'resources_data',
                  to: 'sensor_values#resources_data'
    match ':uuid/data', as: 'resource_data',
                        to: 'sensor_values#resource_data'
    match 'data/last', as: 'resources_data_last',
                       to: 'sensor_values#resources_data_last'
    match ':uuid/data/last', as: 'resource_data_last',
                             to: 'sensor_values#resource_data_last'
    match 'search', as: 'resources_search',
                    to: 'sensor_values#resources_search'
  end
end
