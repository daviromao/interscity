$redis = Redis::Namespace.new('actuator_controller', :redis => Redis.new(:host => "redis", :port => 6379))
