host = ENV["REDIS_HOST"] || "redis"
port = ENV["REDIS_PORT"] || 6379

Sidekiq.configure_server do |config|
  config.redis = { url: "#{host}:#{port}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{host}:#{port}" }
end
