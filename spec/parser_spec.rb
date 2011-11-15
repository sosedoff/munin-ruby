require 'spec_helper'

class ParseTester
  include Munin::Parser
end

describe Munin::Parser do
  before :each do
    @parser = ParseTester.new
  end
  
  it 'parses version request' do
    @parser.parse_version(fixture('version.txt')).should == '1.4.4'
    
    proc { @parser.parse_version("some other response") }.
      should raise_error Munin::InvalidResponse, "Invalid version response"
  end
  
  it 'parses config request' do
    c = @parser.parse_config(fixture('config.txt').strip.split("\n"))
    c.should be_a Hash
    c['graph'].should be_a Hash
    c['graph']['args']['raw'].should == '--base 1024 -l 0 --upper-limit 16175665152'
    c['graph']['args']['parsed'].keys.should == %w(base l upper-limit)
    c['metrics'].should be_an Hash
  end
end
