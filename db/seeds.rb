# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
puts '=' * 50
puts 'This operations will take some time...'
puts '=' * 50

puts '.' * 50
puts 'Removing old data...'
puts '.' * 50

SensorValue.delete_all
PlatformResource.delete_all
Capability.delete_all
PlatformResourceCapability.delete_all

puts '.' * 50
puts 'Creating Platform resource without capability'
puts '.' * 50

def create_resource(uuid, uri, status, interval)
  PlatformResource.create_with(uri: uri,
                               status: status,
                               collect_interval: interval)
                  .find_or_create_by(uuid: uuid)
end

# First, without capability
10.times do
  uri = "/basic_resources/#{Faker::Number.between(1, 50)}/components/" \
             "#{Faker::Number.between(1, 50)}/collect"
  create_resource(SecureRandom.uuid, uri, 'on', Faker::Number.between(60, 1000))
end

puts '.' * 50
puts 'Creating Platform resource with capability'
puts '.' * 50

list_capabilities = []
10.times do
  capability_name = Faker::Hipster.word
  list_capabilities << Capability.create!(name: capability_name)
end

20.times do
  uri = "/basic_resources/#{Faker::Number.between(50, 300)}/components/" \
             "#{Faker::Number.between(50, 300)}/collect"
  resource = create_resource(SecureRandom.uuid,
                             uri,
                             'on',
                             Faker::Number.between(60, 1000))

  total_capability = Faker::Number.between(1, 10)
  total_capability.times do |index|
    cap = list_capabilities[index]
    resource.capabilities << cap
    resource.capabilities.where(name: cap.name).exists?

    Faker::Number.between(1, 5).times do
      SensorValue.create!(capability: cap,
                          platform_resource: resource,
                          date: Faker::Time.between(DateTime.now - 1,
                                                    DateTime.now),
                          value: Faker::Number.decimal(2, 3))
    end

    # string sensor values
    Faker::Number.between(1, 3).times do
      SensorValue.create!(capability: cap,
                          platform_resource: resource,
                          date: Faker::Time.between(DateTime.now - 1,
                                                    DateTime.now),
                          value: Faker::Company.name)
    end

  end
end

puts "Created #{SensorValue.count} 'sensor_values'"
