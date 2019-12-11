# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  # Integration tests should run separately
  integration_test_files_pattern = 'spec/integration/**/*_spec.rb'

  # clears the default 'rake spec' task to overwrite the rspec_opts
  task('spec').clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = FileList['spec/**/*_spec.rb'].exclude(integration_test_files_pattern)
  end
rescue LoadError
  desc 'Run rspec tasks - not available within this environment'
  task :spec do
    abort 'Rspec rake task not available'
  end
end
