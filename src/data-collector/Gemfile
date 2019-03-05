source 'https://rubygems.org'

gem 'rails', '>= 5.0.0', '< 5.1'

gem 'rake'

gem 'mongoid'
gem 'database_cleaner'

gem 'puma', '~> 3.0'

gem 'sass-rails', '~> 5.0'

gem 'jquery-rails'

gem 'jbuilder', '~> 2.0'

gem 'kong'

gem 'faye'
gem 'thin'

gem 'rest-client'

gem 'rack-cors', :require => 'rack/cors'

# RabbitMQ
gem 'bunny', '~> 2.5.1'

# Configure application
gem 'config'

group :development, :test do
  gem 'rspec-rails', '~> 3.5.0.beta4'
  gem 'rspec-expectations', '~> 3.5.0.beta4'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'rails-controller-testing'

  # Call 'byebug' anywhere in the code to stop execution and get a
  # debugger console
  gem 'byebug', platform: :mri
  gem 'rubocop', '~> 0.40.0', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %>
  # anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'simplecov', require: false, group: :test
