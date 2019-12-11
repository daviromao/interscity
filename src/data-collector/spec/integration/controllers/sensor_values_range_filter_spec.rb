# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SensorValuesController, :integration, type: :controller do
  context 'Request with filters' do
    before :each do
      status_opt = 'on'
      uuids_hash = {
        '2de545ae-841a-4e4a-b961-a43bb324a2b9': {
          'environment_monitoring': [
            { 'temperature': '18.5',
              'humidity': '68',
              'air_quality': '1',
              'date': '2016-03-01 09:00:00' },
            { 'temperature': '22.15',
              'humidity': '72',
              'air_quality': '2',
              'date': '2016-03-01 10:00:00' },
            { 'temperature': '27',
              'humidity': '87',
              'air_quality': '7',
              'date': '2016-03-02 08:00:00' },
            { 'temperature': '19.5',
              'humidity': '50',
              'air_quality': '5',
              'date': '2016-03-03 07:00:00' }
          ],
          'luminosity': [
            { 'luminosity': 180,
              'date': '2016-03-01 09:00:00' },
            { 'luminosity': 182,
              'date': '2016-03-01 10:00:00' },
            { 'luminosity': 176,
              'date': '2016-03-02 08:00:00' },
            { 'luminosity': 180,
              'date': '2016-03-03 07:00:00' }
          ]
        },
        '8fcbba32-ea98-4a84-9abf-c97c9c65c3c4': {},
        '989e93f2-35e1-4a2b-b80a-4bf91030085c': {
          'medical_procedure': [
            { 'patient': {
              'name': 'Thomas S. Seibel',
              'age': '18'
            },
              'speciality': 'surgery',
              'date': '2016-03-01 09:01:00' },
            { 'patient': {
              'name': 'Jose R. Garcia',
              'age': '17'
            },
              'speciality': 'psychiatry',
              'date': '2016-03-01 10:01:00' },
            { 'patient': {
              'name': 'Débora M. Wright',
              'age': '26'
            },
              'speciality': 'psychiatry',
              'date': '2016-03-02 08:01:00' },
            { 'patient': {
              'name': 'Jose J. Whetsel',
              'age': '55'
            },
              'speciality': 'surgery',
              'date': '2016-03-03 07:01:00' }
          ]
        },
        'a9f4d13b-1c10-474c-9754-a0a92adcc72d': {
          'environment_monitoring': [
            { 'temperature': '28.5',
              'pressure': '1038',
              'humidity': '70',
              'date': '2016-03-01 09:00:00' },
            { 'temperature': '29.5',
              'pressure': '1012',
              'humidity': '72',
              'date': '2016-03-03 07:00:00' },
            { 'humidity': '67',
              'date': '2016-03-02 08:30:00' },
            { 'humidity': '75',
              'date': '2016-03-03 07:30:00' }
          ],
          'bus_trip': [
            { 'location': {
              'lat': -23.1,
              'lon': -46.8
            },
              'speed': 45.2,
              'occupancy': 10,
              'date': '2016-03-01 09:30:00' },
            { 'location': {
              'lat': -23.2,
              'lon': -46.7
            },
              'speed': 50.8,
              'occupancy': 10,
              'date': '2016-03-01 10:30:00' },
            { 'location': {
              'lat': -23.2,
              'lon': -46.7
            },
              'speed': 62.0,
              'occupancy': 12,
              'date': '2016-03-02 08:30:00' },
            { 'location': {
              'lat': -23.2,
              'lon': -46.4
            },
              'speed': 34.0,
              'occupancy': 9,
              'date': '2016-03-03 07:30:00' }
          ]
        }
      }
      # Creating data on database
      uuids_hash.each do |uuid, capability_hash|
        resource = PlatformResource.create!(uuid: uuid, status: status_opt)

        # Create capabilities
        capability_hash.each do |capability_name, values_list|
          capability = capability_name
          resource.capabilities << capability.to_s
          resource.save!

          values_list.each do |value_hash|
            fields = {
              capability: capability,
              platform_resource_id: resource.id,
              uuid: resource.uuid
            }
            fields.merge!(value_hash)
            SensorValue.create!(fields)
          end
        end
      end
    end

    context 'with the matchers of values parameters' do
      it 'responds with success' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "pressure.gte": 0,
                   "pressure.lte": 22
                 }
               })
          expect(response.status).to eq(200)
          expect(response.body).to_not be_nil
          expect(response.body.empty?).to be_falsy
        end
      end

      it 'correctly list value by their capabilities' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.gte": 0,
                   "temperature.lte": 100
                 }
               })
          retrieved_uuids, retrieved_resource = parse_response

          expect(retrieved_uuids.empty?).to be_falsy
          retrieved_uuids.each do |uuid|
            resource = PlatformResource.find_by(uuid: uuid)
            real_capabilities = resource.capabilities
            retrieved_capabilities = retrieved_resource.select do |element|
              element['uuid'] == uuid
            end.first['capabilities'].keys

            expect(real_capabilities).to include(*retrieved_capabilities)
            expect(['environment_monitoring']).to match_array(retrieved_capabilities)
          end
        end
      end

      it 'returns no resource for a request with inexistent capability values' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "wontfindnocap.gte": 0,
                   "wontfindnocap.lte": 22
                 }
               })
          retrieved_uuids, = parse_response

          expect(retrieved_uuids.size).to eq(0)
        end
      end

      it 'returns the data that match the matchers filters for multiple values' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.gte": 0,
                   "temperature.lte": 100,
                   "humidity.gte": 40
                 }
               })

          retrieved_uuids, = parse_response
          expect(retrieved_uuids.size).to eq(2)
        end
      end

      it 'returns an empty list for invalid gte/lte params' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.gte": 'Zeni',
                   "temperature.lte": 'Foo'
                 }
               })

          retrieved_uuids, = parse_response
          expect(retrieved_uuids.size).to eq(0)
        end
      end

      it 'correctly filter resources data by greater than (gt) operator' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.gt": 22.15
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(2)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['temperature'].to_f).to be > 22.15
            end
          end
        end
      end

      it 'correctly filter resources data by greater than or equal (gte) operator' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.gte": 22.15
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(2)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['temperature'].to_f).to be >= 22.15
            end
          end
        end
      end

      it 'correctly filter resources data by less than (lt) operator' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.lt": 22.15
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(1)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['temperature'].to_f).to be < 22.15
            end
          end
        end
      end

      it 'correctly filter resources data by less than or equal (lte) operator' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.lte": 22.15
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(1)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['temperature'].to_f).to be <= 22.15
            end
          end
        end
      end

      it 'correctly filter resources data by equal (eq) operator on numbers' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.eq": 22.15
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(1)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['temperature'].to_f).to eq(22.15)
            end
          end
        end
      end

      it 'correctly filter resources data by equal (eq) operator on non-numbers' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   'speciality.eq': 'psychiatry'
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(1)
          resources_data.each do |resource|
            resource['capabilities']['medical_procedure'].each do |data|
              expect(data['speciality']).to eq('psychiatry')
            end
          end
        end
      end

      it 'correctly filter resources data by not equal (ne) operator on non-numbers' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 capabilities: ['medical_procedure'],
                 matchers: {
                   'speciality.ne': 'psychiatry'
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(1)
          resources_data.each do |resource|
            resource['capabilities']['medical_procedure'].each do |data|
              expect(data['speciality']).to_not eq('psychiatry')
            end
          end
        end
      end

      it 'correctly filter resources data by in (in) operator' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "humidity.in": [70, 72, 68]
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(2)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect([70, 72, 68]).to include(data['humidity'])
            end
          end
        end
      end

      it 'correctly filter resources data by not in (nin) operator' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 capabilities: ['environment_monitoring'],
                 matchers: {
                   "humidity.nin": [70, 72, 68]
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(2)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect([70, 72, 68]).to_not include(data['humidity'])
            end
          end
        end
      end

      it 'correctly filter resources when mixing several simultaneously' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "temperature.gte": 25,
                   "temperature.lte": 30,
                   "humidity.gt": 40
                 }
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(2)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['humidity']).to be > 40
              expect(data['temperature']).to be >= 25
              expect(data['temperature']).to be <= 30
            end
          end
        end
      end

      it 'returns an empty list for invalid matchers' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "humidity.gte": 100,
                   "humidity.lte": 0
                 }
               })
          returned_json = JSON.parse(response.body)
          retrieved_resource = returned_json['resources']

          expect(retrieved_resource.empty?).to be_truthy
        end
      end

      it 'applies eq operator over othe comparissing operators' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: {
                 matchers: {
                   "humidity.eq": 72,
                   "humidity.gte": 0
                 }
               })
          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(2)
          resources_data.each do |resource|
            resource['capabilities']['environment_monitoring'].each do |data|
              expect(data['humidity']).to eq(72)
            end
          end
        end
      end
    end

    context 'without matchers parameters' do
      it 'correctly filters based on a single capability' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: { capabilities: %w[environment_monitoring] })

          expect(response.status).to eq(200)

          retrieved_uuids, = parse_response
          expect(retrieved_uuids.size).to eq(2)
        end
      end

      it 'correctly filters based on multiple capabilities' do
        %i[post get].each do |verb|
          send(verb, 'resources_data',
               params: { capabilities: %w[environment_monitoring medical_procedure] })

          expect(response.status).to eq(200)

          retrieved_uuids, = parse_response
          expect(retrieved_uuids.size).to eq(3)
        end
      end
    end

    context 'with date-based parameters' do
      it 'responds with success' do
        %i[post get].each do |verb|
          send(verb, 'resources_data', params: {
                 start_date: '2016-01-01 09:21:29',
                 end_date: '2016-03-03 07:00:00'
               })

          expect(response.status).to eq(200)
          expect(response.body).to_not be_nil
          expect(response.body.empty?).to be_falsy
        end
      end

      it 'returns an empty list for a date range with no data' do
        %i[post get].each do |verb|
          send(verb, 'resources_data', params: {
                 start_date: '2016-01-01 09:21:29',
                 end_date: '2016-01-03 07:00:00'
               })

          retrieved_uuids, = parse_response
          expect(retrieved_uuids.size).to eq(0)
        end
      end

      it 'correctly filters for a valid range of date' do
        %i[post get].each do |verb|
          send(verb, 'resources_data', params: {
                 start_date: '2016-02-01 01:03:43',
                 end_date: '2016-06-25 16:03:43'
               })

          retrieved_uuids, resources_data = parse_response
          expect(retrieved_uuids.size).to eq(3)
          resources_data.each do |resource|
            resource['capabilities'].each do |_key, capability|
              capability.each do |data|
                expect(DateTime.parse(data['date'])).to be >= DateTime.parse('2016-02-01 01:03:43')
                expect(DateTime.parse(data['date'])).to be <= DateTime.parse('2016-06-25 16:03:43')
              end
            end
          end
        end
      end
    end

    context 'Most recent data' do
      it 'returns the last value for all uuids' do
        %i[post get].each do |verb|
          send(verb, 'resources_data_last')
          returned_json = JSON.parse(response.body)
          retrieved_resource = returned_json['resources']
          retrieved_uuids = retrieved_resource
                            .map { |element| element['uuid'] }

          retrieved_uuids.each do |uuid|
            platform = PlatformResource.find_by(uuid: uuid)

            json_capabilities = retrieved_resource
                                .select { |element| element['uuid'] == uuid }
                                .first['capabilities']

            platform.capabilities.each do |cap|
              last_values =
                LastSensorValue.where(
                  capability: cap, uuid: platform.uuid
                )
                               .map { |obj| obj.dynamic_attributes.to_json }

              retrieved_values = []
              json_capabilities[cap].each do |capability|
                retrieved_values << capability.to_json
              end
              expect(last_values.size).to eq(1)
              expect(retrieved_values.size).to eq(1)
              expect(retrieved_values.first).to eq(last_values.first)
            end
          end
        end
      end

      it 'returns the last value for one uuid' do
        %i[post get].each do |verb|
          send(verb, 'resource_data_last', params:
                    { uuid: '2de545ae-841a-4e4a-b961-a43bb324a2b9' })
          returned_json = JSON.parse(response.body)
          retrieved_resource = returned_json['resources']
          retrieved_uuids = retrieved_resource
                            .map { |element| element['uuid'] }
          expect(retrieved_uuids.size).to eq(1)
          retrieved_uuids.each do |uuid|
            platform = PlatformResource.find_by(uuid: uuid)
            json_capabilities = retrieved_resource
                                .select { |element| element['uuid'] == uuid }
                                .first['capabilities']
            platform.capabilities.each do |cap|
              last_values =
                LastSensorValue.where(
                  capability: cap, uuid: platform.uuid
                )
                               .map { |obj| obj.dynamic_attributes.to_json }

              retrieved_values = []
              json_capabilities[cap].each do |capability|
                retrieved_values << capability.to_json
              end
              expect(last_values.size).to eq(1)
              expect(retrieved_values.size).to eq(1)
              expect(retrieved_values.first).to eq(last_values.first)
            end
          end
        end
      end

      it 'returns the last value for multiple uuids' do
        %i[post get].each do |verb|
          send(verb, 'resources_data_last', params: {
                 uuids: %w[
                   2de545ae-841a-4e4a-b961-a43bb324a2b9
                   989e93f2-35e1-4a2b-b80a-4bf91030085c
                 ]
               })
          returned_json = JSON.parse(response.body)
          retrieved_resource = returned_json['resources']
          retrieved_uuids = retrieved_resource
                            .map { |element| element['uuid'] }
          expect(retrieved_uuids.size).to eq(2)
          retrieved_uuids.each do |uuid|
            platform = PlatformResource.find_by(uuid: uuid)
            json_capabilities = retrieved_resource
                                .select { |element| element['uuid'] == uuid }
                                .first['capabilities']
            platform.capabilities.each do |cap|
              last_values =
                LastSensorValue.where(
                  capability: cap, uuid: platform.uuid
                ).map { |obj| obj.dynamic_attributes.to_json }

              retrieved_values = []
              json_capabilities[cap].each do |capability|
                retrieved_values << capability.to_json
              end
              expect(last_values.size).to eq(1)
              expect(retrieved_values.size).to eq(1)
              expect(retrieved_values.first).to eq(last_values.first)
            end
          end
        end
      end
    end
  end

  def parse_response
    returned_json = JSON.parse(response.body)
    retrieved_resources = returned_json['resources']
    retrieved_uuids = retrieved_resources
                      .map { |element| element['uuid'] }
    [retrieved_uuids, retrieved_resources]
  end
end
