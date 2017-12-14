require 'mock_redis'

if Rails.env.development? || Rails.env.production?
  host = ENV["REDIS_HOST"] || "redis"
  port = ENV["REDIS_PORT"] || 6379
  db = ENV["REDIS_DB"] || "capabilities"
  $redis = Redis.new(host: host, port: port, db: db)
else # Test environment
  $redis = MockRedis.new
end

