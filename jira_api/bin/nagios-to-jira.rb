#!/usr/bin/env ruby


# This script is triggered by cron and grabs the details of the nagios alert and send it to the 
# local sinatra server.

require 'optparse'
require 'json'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))

require 'log'
require 'pagerduty'

CONF_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', "conf"))

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  
  opts.separator ''
  opts.separator 'Configuration options:'
  
  
  opts.on('-v', '--verbose', "display verbose messages") do |v|
    options[:verbose] = v
  end  
end.parse!

  def data_to_json()
    data = JSON.parse(notification)
  end

  def send_restfully(jdata,problemid,alert_api_key)
    PagerDuty.send_to_pagerduty(jdata,problemid,alert_api_key)
  end
    results = Hash.new

  def filter_alert_results()
    results = Hash.new
    wanted_fields = JSON.parse(File.read(CONF_DIR + '/pagerduty.json'))

    wanted_fields['nagios_fields'].each do |a|
      Log.info("doing #{a}".upcase)
      unless ENV["#{a}".upcase].empty?
        results[:"#{a}"] = ENV["#{a}".upcase]
      end
      Log.info("done: " + results[:"#{a}"])
    end

    return results

  end

  def check_service_alert(results)
    Log.info('cannot send any pages unless contactpager is provided') && exit(1) unless results[:contactpager]
    Log.info('cannot send any pages unless problemid is provided') && exit(1) unless results[:serviceproblemid]
    Log.info('cannot send any pages unless serviceoutput is provided') && exit(1) unless results[:serviceoutput]
    Log.info('cannot send any pages unless servicestate is provided') && exit(1) unless results[:servicestate]
  end 

  def check_host_alert(results)
    Log.info('cannot send any pages unless contactpager is provided') && exit(1) unless results[:contactpager]
    Log.info('cannot send any pages unless problemid is provided') && exit(1) unless results[:hostproblemid]
    Log.info('cannot send any pages unless hostoutput is provided') && exit(1) unless results[:hostoutput]
    Log.info('cannot send any pages unless hoststate is provided') && exit(1) unless results[:hoststate]
  end 

alert = filter_alert_results

# HOSTPROBLEMID and SERVICEPROBLEMID are zero if they are not a HOST alert or SERVICE alert respectively.
# So we are going to test on the presence of zero in one, if it is none zero then it must be that type of alert. 
# We are then going to just set the 'problemid' to one of them. 
if alert[:hostproblemid] == 0 
  check_host_alert(alert)
  alert[:problemid] = alert[:hostproblemid]
  Log.info("this is alertid: " + alert[:problemid])
else
  check_service_alert(alert)
  alert[:problemid] = alert[:serviceproblemid]
  Log.info("this is alertid: " + alert[:problemid])
end

