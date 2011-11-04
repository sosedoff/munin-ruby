# Munin-Ruby

Munin-ruby is a sockets-based ruby client library to communicate and fetch information from munin-node servers.

## Installation

Simple install using rubygems:

```
gem install munin-ruby
```

## Usage

Just require the gem and you're good to go.

```ruby
require 'munin-ruby'

node = Munin::Node.new
node.version # => 1.4.4
```

### Connections

```ruby
# Connects to 127.0.0.1:4949
node = Munin::Node.new
node = Munin::Node.new('YOUR_HOST', YOUR_PORT)
```

If munin-node has any restrictions on IP addresses, client will trigger ```Munin::AccessDenied``` exception.

By default client will reconnect if connection was lost. To disable that specify ```false``` after port option.

```ruby
node = Munin::Node.new('YOUR_HOST', 4949, false)
```

Ways to disconnect:

```
# Disconnect from server
node.disconnect
node.connection.close
```

In case if automatic reconnection was enabled, service will establish connection even after you call 'disconnect' method.

To force client not to open connection: ```node.disconnect(false)```. 

This will trigger ```Munin::ConnectionError``` on any client calls.

### Services and metrics

See what's available on server:

```ruby
services = node.list 

# => ["cpu","df", "df_inode", "entropy", "forks", ...]
```

#### Get service configuration

```ruby
config = node.config('cpu')
```

This will produce the following result:

```
{:graph=>
  {"title"=>"CPU usage",
   "order"=>"system user nice idle iowait irq softirq",
   "args"=>{"base"=>"1000", "lower-limit"=>"0", "upper-limit"=>"400"},
   "vlabel"=>"%",
   "scale"=>"no",
   "info"=>"This graph shows how CPU time is spent.",
   "category"=>"system",
   "period"=>"second"},
 :metrics=>
  {"system"=>
    {"label"=>"system",
     "draw"=>"AREA",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>"CPU time spent by the kernel in system activities"},
   "user"=>
    {"label"=>"user",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>"CPU time spent by normal programs and daemons"},
   "nice"=>
    {"label"=>"nice",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>"CPU time spent by nice(1)d programs"},
   "idle"=>
    {"label"=>"idle",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>"Idle CPU time"},
   "iowait"=>
    {"label"=>"iowait",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>
      "CPU time spent waiting for I/O operations to finish when there is nothing else to do."},
   "irq"=>
    {"label"=>"irq",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>"CPU time spent handling interrupts"},
   "softirq"=>
    {"label"=>"softirq",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>"CPU time spent handling \"batched\" interrupts"},
   "steal"=>
    {"label"=>"steal",
     "draw"=>"STACK",
     "min"=>"0",
     "type"=>"DERIVE",
     "info"=>
      "The time that a virtual CPU had runnable tasks, but the virtual CPU itself was not running"}}}
```


#### Fetch a single service

```ruby
service = node.fetch('cpu')
```

Output:

```
{"user"=>"140349907",
 "nice"=>"0",
 "system"=>"19694121",
 "idle"=>"536427034",
 "iowait"=>"6455996",
 "irq"=>"445",
 "softirq"=>"482942",
 "steal"=>"635801"}
```

  
## License

Copyright © 2011 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
