module ComponentServices
  module Foo
    def collect_temperature
      10
    end
    def collect_humidity
      8
    end
    def actuate_temperature(temperature)
      return temperature
    end
  end
end

module DataHelper
  def create_resources(resources = 1, components = 3)
    (1..resources).each do |i|
      resource = BasicResource.create!(
        name: "Arduino",
        model: "Uno",
        maker: "XPTO"
      )

      (1..components).each do |i|
        resource.components << Component.new(
          description: "Text #{i}",
          service_type: 'Foo',
          lat: (-23 + i/10.0),
          lon: (-46 + i/10.0),
          collect_interval: 60,
          capabilities: ["temperature", "humidity"]
        )
      end
    end
  end
end
