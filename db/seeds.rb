# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

BasicResource.create(uri: "sbrubles.com")
BasicResource.create(uri: "notsbrubles.com")
BasicResource.create(uri: "maybesbrubles.com")


Capability.create_sensor(name: "air-quality")
Capability.create_sensor(name: "air-humidity")
Capability.create_sensor(name: "parking-occupancy")
Capability.create_sensor(name: "video")
Capability.create_sensor(name: "queue-length")
Capability.create_actuator(name: "semaphore")
Capability.create_actuator(name: "illuminate")
Capability.create_information(name: "parking-type")

# Health Facilities
Capability.create_sensor(name: "current_users")
Capability.create_information(name: "info_facility_type")
Capability.create_information(name: "info_total_capacity")

# ParkingSpot
Capability.create_sensor(name: "spot_availability")
Capability.create_sensor(name: "availability_schedules")

# SportsMaps
Capability.create_sensor(name: "humidity")
Capability.create_sensor(name: "temperature")
Capability.create_sensor(name: "uv")
Capability.create_sensor(name: "pollution")
Capability.create_information(name: "info_green_percentage")

# TrafficFlow
Capability.create_sensor(name: "traffic_speed")
Capability.create_sensor(name: "traffic_density")
Capability.create_actuator(name: "traffic_light_status")

# ArduinoDemo
Capability.create_actuator(name: "arduino_traffic_light")
Capability.create_actuator(name: "arduino_luminosity")

# Extra
Capability.create_sensor(name: "location")
