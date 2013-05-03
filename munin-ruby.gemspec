# -*- encoding: utf-8 -*-
require File.expand_path('../lib/munin-ruby/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name            = "munin-ruby"
  gem.version         = Munin::VERSION.dup
  gem.author          = "Dan Sosedoff"
  gem.email           = "dan.sosedoff@gmail.com"
  gem.homepage        = "http://github.com/sosedoff/munin-ruby"
  gem.description     = "Munin Node client"
  gem.summary         = "Ruby client library to communicate with munin-node servers"
  
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']
  
  gem.add_development_dependency 'rspec', '~> 2.13'
end