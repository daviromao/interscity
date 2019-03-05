r = PlatformResource.pluck(:uuid)
s = LastSensorValue.pluck(:uuid)

diff = r - s
init = 0
finish = 10000

while init <= diff.count
  PlatformResource.where(uuid: {"$in" => diff[init..finish]}).each do |resource|
    begin
      if diff.include? resource.uuid
        LastSensorValue.create!( platform_resource: resource, uuid: resource.uuid, date: Time.now, capability: "parking_monitoring", available: "true")
        print '.'
      else
        print '-'
      end
    rescue
      print 'F'
    end
  end
  init = finish + 1
  finish += 10000
end
