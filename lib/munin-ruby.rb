require 'rubygems'
require 'socket'

begin
  require 'system_timer'
rescue LoadError
  require 'timeout'
end

module Munin
  TIMEOUT_TIME = 10

  if defined?(SystemTimer)
    TIMEOUT_CLASS = SystemTimer
  else
    TIMEOUT_CLASS = Timeout
  end
end

require 'munin-ruby/version'
require 'munin-ruby/errors'
require 'munin-ruby/parser'
require 'munin-ruby/cache'
require 'munin-ruby/connection'
require 'munin-ruby/node'

