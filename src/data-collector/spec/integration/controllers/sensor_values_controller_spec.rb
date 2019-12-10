# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SensorValuesController, :integration, type: :controller do
  let(:sensor_value_default) { create(:default_sensor_value) }

  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  it 'Has a valid factory' do
    expect(sensor_value_default).to be_valid
  end

  RSpec.shared_examples 'check http status' do |description, target, status|
    it ": #{description}" do
      post target
      expect(response).to have_http_status(status)
    end
  end

  context 'request resources/data' do
    context 'with paginated connection' do
      before(:all) do
        use_array_as_mongo_collection
        @sensor = FactoryGirl.build(:default_sensor_value)
      end

      context 'with unset limit param' do
        subject { post :resources_data }

        it 'correctly limit the results to the default value' do
          svs = Array.new(1025, @sensor)
          expect(SensorValue).to receive(:all).and_return(svs)

          subject
          resources = JSON.parse(response.body)['resources']
          first_resource = resources[0]
          temperature_data = first_resource['capabilities']['temperature']
          expect(temperature_data.count).to eq(1000)
        end
      end

      context 'with set limit param' do
        subject { post :resources_data, params: { limit: 100 } }

        it 'correctly limit the results to the param sended' do
          svs = Array.new(1025, @sensor)
          expect(SensorValue).to receive(:all).and_return(svs)

          subject
          resources = JSON.parse(response.body)['resources']
          first_resource = resources[0]
          temperature_data = first_resource['capabilities']['temperature']
          expect(temperature_data.count).to eq(100)
        end
      end
    end

    context 'with valid params' do
      before :each do
        generate_data(4)
      end

      message = 'Simple request to resource_data, expect success'
      include_examples 'check http status', message, 'resources_data', :success

      message = 'returns a 200 status code when accessing normally'
      include_examples 'check http status', message, 'resources_data', 200

      it 'returns a json object array' do
        %i[post get].each do |verb|
          send(verb, 'resources_data')
          expect(response.content_type).to eq('application/json')
        end
      end

      it 'renders the correct json and completes the url route' do
        %i[post get].each do |verb|
          send(verb, 'resources_data', format: :json)
          expect(response.status).to eq(200)
          expect(response.body).to_not be_nil
          expect(response.body.empty?).to be_falsy
          expect(response.content_type).to eq('application/json')
        end
      end

      it 'filters by capabilities values range' do
        do_range_value_filter('resources_data', false)
      end

      it 'filters by capabilities equal value' do
        do_equal_value_filter('resources_data', false, sensor_value_default.dynamic_attributes)
      end

      it 'Returns 400 status code when sending invalid data ranges arguments' do
        do_wrong_date_filter('resources_data', false)
      end

      it 'fails when sending invalid pagination arguments' do
        do_wrong_pagination_filter('resources_data', false)
      end

      context 'Verify request with uuid : ' do
        it 'Correct response, using only one uuid inside Array' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: [@uuids[0]] })
            expect(response.status).to eq(200)
            expect(response.body).to_not be_nil
            expect(response.body.empty?).to be_falsy
          end
        end

        it 'Correct response, using more than one uuid inside Array' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: @uuids })
            expect(response.status).to eq(200)
            expect(response.body).to_not be_nil
            expect(response.body.empty?).to be_falsy
          end
        end

        it 'Correct return of single uuid' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: [@uuids[0]] })
            returned_json = JSON.parse(response.body)

            retrieved_resource = returned_json['resources']
            expect(retrieved_resource.size).to eq(1)
            uuid = retrieved_resource.first['uuid']
            expect(uuid).to eq(@uuids[0])
          end
        end

        it 'Correct return of multiple uuids' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: @uuids })
            returned_json = JSON.parse(response.body)
            retrieved_resource = returned_json['resources']

            expect(retrieved_resource.size).to eq(@uuids.size)

            uuids = retrieved_resource.map { |element| element['uuid'] }
            expect(uuids).to match_array(@uuids)
          end
        end

        it 'Correct list of capabilities for one uuid' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: [@uuids[0]] })
            returned_json = JSON.parse(response.body)
            retrieved_resource = returned_json['resources']
            json_capabilities = retrieved_resource.first['capabilities']

            platform = PlatformResource.find_by(uuid: @uuids[0])
            real_capabilities = platform.capabilities
            retrieved_capabilities = json_capabilities.keys

            expect(real_capabilities).to match_array(retrieved_capabilities)
          end
        end

        it 'Correct list of capabilities for multiple uuids' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: @uuids })
            returned_json = JSON.parse(response.body)
            retrieved_resource = returned_json['resources']

            @uuids.each do |uuid|
              platform = PlatformResource.find_by(uuid: uuid)
              real_capabilities = platform.capabilities

              retrieved_capabilities = retrieved_resource.select do |element|
                element['uuid'] == uuid
              end.first['capabilities'].keys

              expect(real_capabilities).to match_array(retrieved_capabilities)
            end
          end
        end

        it 'Correct returned sensors values with one uuid' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: [@uuids[0]] })
            returned_json = JSON.parse(response.body)

            retrieved_resource = returned_json['resources']
            json_capabilities = retrieved_resource.first['capabilities']

            platform = PlatformResource.find_by(uuid: @uuids[0])
            platform.capabilities.each do |cap|
              sensor_values = SensorValue.where(capability: cap,
                                                platform_resource_id: platform.id)
                                         .map(&:dynamic_attributes)
              sensor_values.each do |item|
                item['date'] = item['date'].as_json
              end

              retrieved_values = []

              json_capabilities[cap].each do |capability|
                retrieved_values << capability
              end
              expect(sensor_values).to match_array(retrieved_values)
            end
          end
        end

        it 'Correct returned sensors values with multiple uuids' do
          %i[post get].each do |verb|
            send(verb, 'resources_data', params: { uuids: @uuids[0] })
            returned_json = JSON.parse(response.body)

            retrieved_resource = returned_json['resources']

            @uuids.each do |uuid|
              platform = PlatformResource.find_by(uuid: uuid)

              json_capabilities = retrieved_resource
                                  .select { |element| element['uuid'] == uuid }
                                  .first['capabilities']
              platform.capabilities.each do |cap|
                sensor_values = SensorValue
                                .where(capability: cap,
                                       platform_resource_id: platform.id)
                                .pluck(:value)
                retrieved_values = []
                json_capabilities[cap].each do |capability|
                  retrieved_values << capability['value']
                end
                expect(sensor_values).to match_array(retrieved_values)
              end
            end
          end
        end
      end
    end
  end

  describe 'request resources/:uuid/data' do
    it 'returns http success' do
      %i[post get].each do |verb|
        send(verb, 'resource_data', params:
                  { uuid: sensor_value_default.platform_resource.uuid })
        expect(response.status).to eq(200)
      end
    end

    it 'returns a 200 status code when accessing normally' do
      %i[post get].each do |verb|
        send(verb, 'resource_data', params:
                  { uuid: sensor_value_default.platform_resource.uuid })
        expect(response.status).to eq(200)
      end
    end

    it 'returns a json object array' do
      %i[post get].each do |verb|
        send(verb, 'resource_data', params:
                  { uuid: sensor_value_default.platform_resource.uuid })
        expect(response.content_type).to eq('application/json')
      end
    end

    it 'renders the correct json and completes the url route' do
      %i[post get].each do |verb|
        send(verb, 'resource_data', params:
                  { uuid: sensor_value_default.platform_resource.uuid }, format: :json)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq('application/json')
      end
    end

    it 'returns a 404 status code when sending an invalid resource uuid' do
      invalid_uuids = [-5, 2.3, 'foobar']

      invalid_uuids.each do |uuid|
        %i[post get].each do |verb|
          send(verb, 'resource_data', params: { uuid: uuid })
          expect(response.status).to eq(404)
        end
      end
    end

    it 'returns 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resource_data', true)
    end

    # it 'filters by capabilities values range' do
    # do_range_value_filter('resource_data', true)
    # end

    # it 'filters by capabilities equal value' do
    # do_equal_value_filter('resource_data', true, sensor_value_default.value)
    # end

    it 'fails when sending invalid pagination arguments' do
      do_wrong_pagination_filter('resource_data', true)
    end
  end

  describe 'request resources/data/last' do
    it 'returns http success' do
      %i[post get].each do |verb|
        send(verb, 'resources_data_last')
        expect(response).to have_http_status(:success)
      end
    end

    it 'returns a 200 status code when accessing normally' do
      %i[post get].each do |verb|
        send(verb, 'resources_data_last')
        expect(response.status).to eq(200)
      end
    end

    it 'returns a json object array' do
      %i[post get].each do |verb|
        send(verb, 'resources_data_last')
        expect(response.content_type).to eq('application/json')
      end
    end

    it 'renders the correct json and completes the url route' do
      %i[post get].each do |verb|
        send(verb, 'resources_data_last')
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq('application/json')
      end
    end

    it 'returns 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resources_data_last', false)
    end

    # it 'filters by capabilities values range' do
    # do_range_value_filter('resources_data_last', false)
    # end

    # it 'filters by capabilities equal value' do
    # do_equal_value_filter('resources_data_last',
    # false, sensor_value_default.value)
    # end

    it 'fails when sending invalid pagination arguments' do
      do_wrong_pagination_filter('resources_data_last', false)
    end
  end

  describe 'request resources/:uuid/data/last' do
    it 'returns http success' do
      %i[post get].each do |verb|
        send(verb, 'resource_data_last', params: { uuid: sensor_value_default
          .platform_resource.uuid })
        expect(response).to have_http_status(:success)
      end
    end

    it 'returns a 200 status code when accessing normally' do
      %i[post get].each do |verb|
        send(verb, 'resource_data_last', params: { uuid: sensor_value_default
          .platform_resource.uuid })
        expect(response.status).to eq(200)
      end
    end

    it 'returns a json object array' do
      %i[post get].each do |verb|
        send(verb, 'resource_data_last', params: { uuid: sensor_value_default
          .platform_resource.uuid })
        expect(response.content_type).to eq('application/json')
      end
    end

    it 'renders the correct json and completes the url route' do
      %i[post get].each do |verb|
        send(verb, 'resource_data_last', params: { uuid: sensor_value_default
          .platform_resource.uuid }, format: :json)
        expect(response.status).to eq(200)
        expect(response.body).to_not be_nil
        expect(response.body.empty?).to be_falsy
        expect(response.content_type).to eq('application/json')
      end
    end

    it 'returns a 404 status code when sending an invalid resource uuid' do
      invalid_uuids = [-5, 2.3, 'foobar']

      invalid_uuids.each do |uuid|
        %i[post get].each do |verb|
          send(verb, 'resource_data_last', params: { uuid: uuid })
          expect(response.status).to eq(404)
        end
      end
    end

    it 'Returns 400 status code when sending invalid data ranges argunments' do
      do_wrong_date_filter('resource_data_last', true)
    end

    # it 'filters by capabilities values range' do
    # do_range_value_filter('resource_data_last', true)
    # end

    # it 'filters by capabilities equal value' do
    # do_equal_value_filter('resource_data_last',
    #    true, sensor_value_default.value)
    # end

    it 'fails when sending invalid pagination arguments' do
      do_wrong_pagination_filter('resource_data_last', true)
    end
  end

  def do_wrong_date_filter(route, use_uuid)
    err_data = ['foobar', 9.68]

    err_data.each do |data|
      params = { uuid: sensor_value_default.platform_resource.uuid,
                 start_date: data, end_date: data }
      params.except!(:uuid) unless use_uuid

      %i[post get].each do |verb|
        send(verb, route, params: params)
        expect(response.status).to eq(400)
      end
    end
  end

  def do_range_value_filter(route, _use_uuid)
    params = {
      uuid: sensor_value_default.platform_resource.uuid,
      range: {
        'temperature.gte': 20,
        'temperature.lte': 70
      }
    }

    %i[post get].each do |verb|
      send(verb, route, params: params)
    end

    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy
    expect(response.content_type).to eq('application/json')
  end

  def do_equal_value_filter(route, _use_uuid, dynamic_attributes)
    params = {
      uuid: sensor_value_default.platform_resource.uuid,
      range: {
        'temperature.eq': dynamic_attributes['temperature'],
        'pressure.eq': dynamic_attributes['pressure']
      }
    }

    %i[post get].each do |verb|
      send(verb, route, params: params)
    end

    expect(response.status).to eq(200)
    expect(response.body).to_not be_nil
    expect(response.body.empty?).to be_falsy
    expect(response.content_type).to eq('application/json')
  end

  def do_wrong_pagination_filter(route, use_uuid)
    foo_limits = [-1, 1.23, 'foobar']
    foo_starts = [-4, 9.87, 'barfoo']

    # Expect errors with all combinations of invalid arguments and verbs
    %i[post get].each do |verb|
      foo_limits.each do |limit|
        params = { uuid: sensor_value_default
                 .platform_resource.uuid, limit: limit }
        params.except!(:uuid) unless use_uuid

        send(verb, route, params: params)
        expect(response.status).to eq(400)
        params.except!(:limit)

        foo_starts.each do |start|
          params[:start] = start
          send(verb, route, params: params)
          expect(response.status).to eq(400)

          params[:limit] = limit
          send(verb, route, params: params)
          expect(response.status).to eq(400)
        end
      end
    end
  end

  def use_array_as_mongo_collection
    Array.class_eval do
      def limit(lim)
        entry = FactoryGirl.create(:default_sensor_value)
        lim = lim.to_i
        Array.new(lim, entry)
      end

      def offset(_lim)
        self
      end
    end
  end

  def generate_data(total)
    status_opt = %w[on off unknown wtf]
    capability = 'environment_monitoring'
    list_of_data = %w[no temperature humidity pressure]
    @uuids = []

    # Creating data on database
    total.times do |index|
      @uuids.push(SecureRandom.uuid)
      resource = PlatformResource.create!(
        uuid: @uuids[index],
        status: status_opt[rand(status_opt.size)]
      )

      resource.capabilities << capability
      total_cap = Faker::Number.between(1, 3)
      # Create capabilities
      total_cap.times do |i|
        data = list_of_data[i]

        2.times do |_j|
          sensor_value = SensorValue.new(
            capability: capability,
            platform_resource: resource,
            date: Faker::Time.between(DateTime.now - 1, DateTime.now)
          )
          sensor_value[data] = Faker::Number.decimal(2, 3)
          sensor_value.save!
        end
      end
    end
  end
end
