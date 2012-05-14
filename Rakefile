require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--backtrace']
  # spec.ruby_opts = ['-w']
end

task :default => :spec

task :test_rubies do
  system "rvm 1.8.7@brightcove-api_gem,1.9.2@brightcove-api_gem,1.9.3@brightcove-api_gem do rake spec"
end