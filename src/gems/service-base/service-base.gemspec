
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "service/base/version"

Gem::Specification.new do |spec|
  spec.name          = "service-base"
  spec.version       = Service::Base::VERSION
  spec.authors       = ["Rafael Reggiani Manzo"]
  spec.email         = ["rr.manzo@protonmail.com"]

  spec.summary       = %q{Base for InterSCity services.}
  spec.description   = %q{It is expected to hold gems and configuration files that are shared by more than one service. Its main objective is to eliminate repetitions between services making maintenance easier.}
  spec.homepage      = "https://gitlab.com/interscity/interscity-platform/interscity-platform"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '~> 5.0.0'
  spec.add_dependency 'sqlite3', '~> 1.3.13'
  spec.add_dependency 'pg', '~> 0.21.0'
  spec.add_dependency 'kong', '~> 0.3.1'
  spec.add_dependency 'puma', '~> 3.0'
  spec.add_dependency 'rack-cors', '~> 1.0.2'
  spec.add_dependency 'rest-client', '~> 2.0.2'
  spec.add_dependency 'bunny', '~> 2.5.1'
  spec.add_dependency 'jbuilder', '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
