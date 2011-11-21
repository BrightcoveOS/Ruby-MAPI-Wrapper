require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test_rubies

task :test_rubies do
  system "rvm 1.8.7@brightcove-api_gem,1.9.2@brightcove-api_gem,1.9.3@brightcove-api_gem do rake test"
end