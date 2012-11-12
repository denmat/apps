#!/usr/bin/env ruby

require 'rb-inotify'
require 'digest/md5'
require 'optparse'
require 'json'

OPTIONS = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  
  opts.separator ''
  opts.separator 'Configuration options: '

  opts.on('-c', '--conf CONFIGURATION', "Configuration directory") do |c|
    OPTIONS[:conf] = c 
  end

end.parse!

puts OPTIONS[:conf]

CONFIG = JSON.parse(File.read(OPTIONS[:conf] + '/shipping.json'))
SHIP_SEND_DIR = CONFIG['ship_send_dir']


def watcher(notifier)
  puts "looping...."
  @time = Time.now.strftime("%m%d%H%M")
  notifier.watch(@DIRECTORY, :create, ) do |event|
    File.open("#{SHIP_SEND_DIR}/ship_#{@time}", "a+") do |f|
      md5 = Digest::MD5.hexdigest(File.read("#{@DIRECTORY}/#{event.name}"))
      f.puts "#{@DIRECTORY}" + event.name + ',' + md5
      @time = Time.now.strftime("%m%d%H%M")
    end
  end
  notifier.run
end

@DIRECTORY = OPTIONS[:directory]

t = 0
while t < 10  
  notifier = INotify::Notifier.new
  watcher(notifier)
end