# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'brightcove-api-version'

Gem::Specification.new do |s|
  s.name        = "brightcove-api"
  s.version     = Brightcove::API::VERSION
  s.authors     = ["David Czarnecki"]
  s.email       = ["dczarnecki@agoragames.com"]
  s.homepage    = "http://github.com/BrightcoveOS/Ruby-MAPI-Wrapper"
  s.summary     = %q{Ruby gem for interacting with the Brightcove media API}
  s.description = %q{Ruby gem for interacting with the Brightcove media API. http://docs.brightcove.com/en/media/}

  s.rubyforge_project = "brightcove-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('httparty')
  s.add_dependency('json')
  s.add_dependency('rest-client')
  s.add_dependency('multipart-post')
  s.add_dependency('orderedhash')
  
  s.add_development_dependency('fakeweb')
  s.add_development_dependency('mocha')
  s.add_development_dependency('rake')
end