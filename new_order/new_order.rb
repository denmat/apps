#!/usr/bin/env ruby

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "lib")))

# This program sort through file directories and finds matching files
require 'server'
require 'search'
require 'rubygems'
require 'optparse'

@options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} --directory --redis_host --redis_port "

  opts.on('-d', '--directory DIRECTORY', 'Required directory to search') do |dir|
    @options[:directory] = dir
  end
  
  opts.on('-r', '--redis_host REDIS', 'Optional Redis host') do |red|
    @options[:redis_host] = red
  end

  opts.on('-p', '--redis_port PORT', 'Optional Redis port') do |p|
    @options[:redis_port] = p
  end

end

parser.parse!

begin 
  redis_connection = Server.redis(@options[:redis_host],@options[:redis_port])
rescue Redis::CannotConnectError
  fail "cannot connect to Redis server, #{$!}"
end

begin 
  Search.find_file(@options[:directory],redis_connection)
rescue
  fail "could not search files, #{$!}"
end

begin 
   puts redis_connection.lpop('file4')
rescue Redis::ConnectionError
  fail "cannot connect to Redis server, #{$!}"
end
