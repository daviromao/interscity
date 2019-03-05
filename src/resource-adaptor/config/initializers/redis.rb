$redis = Redis::Namespace.new('resource_adaptor', :redis => Redis.new(:host => "redis", :port => 6379))
