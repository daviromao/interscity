# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
puts '=' * 50
puts 'This operations will take some time...'
puts '=' * 50

p "Removing old events/details entries..."

Detail.delete_all
Event.delete_all

p "Creating new events..."

100.times do |index|
  # SecureRandom creates fake uuid codes, based on RFC4122
  event = Event.create!(resource_uuid: SecureRandom.uuid,
                        date: Faker::Time.between(DateTime.now - 1, DateTime.now))

  3.times do |j|
    event.detail.create!(component_uuid: SecureRandom.uuid,
             capability: ["temperature", "pressure", "humidity",
                          "luminosity", "manipulate_led"].sample,
             data_type: "double",
             unit: "none", # Unit must be specific depending on the data type
             value: Faker::Number.decimal(2, 3)
      )
  end
end

p "Created #{Event.count} events"

puts '.' * 50
puts 'Removing old data...'
puts '.' * 50

PlatformResource.delete_all
Capability.delete_all
PlatformResourceCapability.delete_all

puts '.' * 50
puts 'Creating Platform resource without capability'
puts '.' * 50

def create_resource(uuid, uri, status, interval)
  PlatformResource.create!(uuid: uuid,
                            uri: uri,
                            status: status,
                            collect_interval: interval)
end

# First, without capability
10.times do |index|
  uri = "/basic_resources/#{Faker::Number.between(1,50)}/components/" +
             "#{Faker::Number.between(1,50)}/collect"
  create_resource(SecureRandom.uuid, uri, 'on', Faker::Number.between(60, 1000))
end

puts '.' * 50
puts 'Creating Platform resource with capability'
puts '.' * 50
20.times do |index|
  uri = "/basic_resources/#{Faker::Number.between(50,300)}/components/" +
             "#{Faker::Number.between(50,300)}/collect"
  resource = create_resource(SecureRandom.uuid,
                  uri,
                  'on',
                  Faker::Number.between(60, 1000))


  total_capability = Faker::Number.between(1, 20)
  total_capability.times do |index|
    capability_name = Faker::Hipster.word
    cap = Capability.create(name: capability_name)
    resource.capabilities << cap
  end
end
