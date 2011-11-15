require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "brightcove-api"
  gem.homepage = "http://github.com/BrightcoveOS/Ruby-MAPI-Wrapper"
  gem.license = "MIT"
  gem.summary = %Q{Ruby gem for interacting with the Brightcove media API}
  gem.description = %Q{Ruby gem for interacting with the Brightcove media API. http://docs.brightcove.com/en/media/}
  gem.email = "dczarnecki@agoragames.com"
  gem.authors = ["David Czarnecki"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "brightcove-api #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test_rubies

task :test_rubies do
  system "rvm 1.8.7@brightcove-api_gem,1.9.2@brightcove-api_gem do rake test"
end