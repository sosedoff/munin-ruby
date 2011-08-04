# -*- encoding: utf-8 -*-
require File.expand_path('../lib/munin/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "munin-ruby"
  s.version     = Munin::VERSION
  s.description = "Munin Node client"
  s.summary     = "Ruby client library to communicate with munin-node servers"
  s.authors     = ["Dan Sosedoff"]
  s.email       = "dan.sosedoff@gmail.com"
  s.homepage    = "http://github.com/sosedoff/munin-ruby"
  
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']
end