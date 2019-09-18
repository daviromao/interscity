# frozen_string_literal: true

require 'kong'

module Service
  module Base
    module KongLib
      class Wrapper
        def initialize(self_host)
          @self_host = self_host
          @self_host_with_http = 'http://' + @self_host unless @self_host.start_with?('http')
        end

        def register_as_target(name, upstream_name, weight = 100)
          if name.blank? || upstream_name.blank?
            raise 'Missing required parameters for proxy configuration: name, upstream_name'
          end

          upstream = find_or_create_upstream(upstream_name)
          find_or_create_api(name, upstream_name)

          Kong::Target.new(
            upstream_id: upstream.id,
            target: @self_host,
            weight: weight
          ).save

          Rails.logger.info 'Target was succesfully registered to Kong'
        rescue StandardError => e
          raise StandardError, "Could not register target to Kong #{e.message}"
        end

        def register_as_api(name, uris)
          raise 'Missing required parameters for proxy configuration: name, uris' if name.blank? || uris.blank?

          Kong::Api.new(
            name: name,
            upstream_url: @self_host_with_http,
            uris: uris,
            strip_uri: true
          )

          Rails.logger.info 'API was succesfully registered to Kong'
        rescue StandardError => e
          Rails.logger.error "Could not register API to Kong #{e.message}"
        end

        private

        def find_or_create_upstream(upstream_name)
          # rubocop:disable Rails/DynamicFindBy
          # find_by(name: name) is not supported by the kong gem
          upstream = Kong::Upstream.find_by_name(upstream_name)
          # rubocop:enable Rails/DynamicFindBy

          if upstream.nil?
            upstream = Kong::Upstream.new(name: upstream_name)
            upstream.save
          end

          upstream
        end

        def find_or_create_api(name, upstream_name)
          # rubocop:disable Rails/DynamicFindBy
          # find_by(name: name) is not supported by the kong gem
          api = Kong::Api.find_by_name(name)
          # rubocop:enable Rails/DynamicFindBy

          if api.nil?
            api = Kong::Api.new(
              name: name,
              upstream_url: "http://#{upstream_name}",
              uris: "/#{name}",
              strip_uri: true
            )
            api.save
          end

          api
        end
      end
    end
  end
end
