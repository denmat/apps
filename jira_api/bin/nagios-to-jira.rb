#!/usr/bin/env ruby

# This script is triggered by cron and grabs the details of the nagios alert and send it to the 
# local sinatra server.

require 'optparse'
require 'json'
require 'rest_client'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  
  opts.separator ''
  opts.separator 'Configuration options:'
  
  
  opts.on('-v', '--verbose', "display verbose messages") do |v|
    options[:verbose] = v
  end  
end.parse!

def nagios_to_json(notification)
  data = JSON.parse(notification)
end

def send_restfully(data)
  response = RestClient.post 'http://localhost:4567/trigger', { :data => jdata }, {:content_type => :json, :accept => :json}
end