require 'mocha'
require 'rspec'
require 'vcr'
require 'brightcove-api'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
  c.default_cassette_options = { :serialize_with => :json }
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
  config.mock_framework = :mocha
end