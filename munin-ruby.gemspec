require 'lib/munin-ruby/version'

Gem::Specification.new do |s|
  s.name        = "munin-ruby"
  s.version     = Munin::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.description = "munin-node ruby client"
  s.summary     = "Ruby client library to communicate with munin-node servers"
  s.authors     = ["Dan Sosedoff"]
  s.email       = "dan.sosedoff@gmail.com"
  s.homepage    = "http://github.com/sosedoff/munin-ruby"

  s.files = %w[
    README.rdoc
    lib/munin-ruby.rb
    lib/munin-ruby/version.rb
    lib/munin-ruby/node.rb
    lib/munin-ruby/stat.rb
    lib/munin-ruby/munin-ruby.rb
  ]
end