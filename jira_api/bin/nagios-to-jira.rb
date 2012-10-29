#!/usr/bin/env ruby


# This script is triggered by cron and grabs the details of the nagios alert and send it to the 
# local sinatra server.

require 'optparse'
require 'json'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))

require 'log'
require 'pagerduty'
require 'shorturl'

include Log
include Pagerduty
include Shorturl

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

VERBOSE = options[:verbose]

  def data_to_json(alert)
    data = JSON.parse(alert)
  end

def filter_alert_results()
    results = Hash.new
    wanted_fields = JSON.parse(File.read(CONF_DIR + '/pagerduty.json'))

    wanted_fields['nagios_fields'].each do |a|
      Log.info("doing #{a}".upcase) if VERBOSE
      unless ENV["#{a}".upcase] == nil or ENV["#{a}".upcase].empty?
        results[:"#{a}"] = ENV["#{a}".upcase]
      end
      unless results[:"#{a}"] == nil or results[:"#{a}"].empty?
        Log.info("done: " + results[:"#{a}"])  if VERBOSE 
      end
    end
    return results

  end

  def check_service_alert(results)
    Log.fatal('cannot send any pages unless contactpager is provided') && exit(1) unless results[:contactpager]
    Log.fatal("contactpager is the wrong length, needs to be 32 characters, is #{results[:contactpager].length}") && exit(1) unless results[:contactpager].length == 32
    Log.fatal('cannot send any pages unless problemid is provided') && exit(1) unless results[:serviceproblemid]
    Log.fatal('cannot send any pages unless serviceoutput is provided') && exit(1) unless results[:serviceoutput]
    Log.fatal('cannot send any pages unless servicestate is provided') && exit(1) unless results[:servicestate]
  end 

  def check_host_alert(results)
    Log.fatal('cannot send any pages unless contactpager is provided') && exit(1) unless results[:contactpager]
    Log.fatal("contactpager is the wrong length, needs to be 32 characters, is #{results[:contactpager].length}") && exit(1) unless results[:contactpager].length == 32
    Log.fatal('cannot send any pages unless problemid is provided') && exit(1) unless results[:hostproblemid]
    Log.fatal('cannot send any pages unless hostoutput is provided') && exit(1) unless results[:hostoutput]
    Log.fatal('cannot send any pages unless hoststate is provided') && exit(1) unless results[:hoststate]
  end 

# Get the alert details we want from Nagios
results = filter_alert_results

# HOSTPROBLEMID and SERVICEPROBLEMID are zero if they are not a HOST alert or SERVICE alert respectively.
# So we are going to test on the presence of zero in one, if it is none zero then it must be that type of alert. 
# We are then going to just set the 'problemid' to one of them. 
# Then we need to build the right hash for the PagerDuty API requirements
# It requires the following json data (at a minimum):
#   {
#      "service_key": @alert_api_key,  # this comes from the CONTACTPAGER var passed by nagios
#      "inicident_key": @problemid,  # this comes from nagios PROBLEMID
#      "event_type": "trigger"||"acknowledge"||"resolved",
#      "description": "Reason for failure",  # this gets posted as the SMS details.
#      "details": {
#        "someotherdetail": "value"
#      }
#   }
alert = Hash.new
if alert[:hostproblemid] == 0 
  check_host_alert(results)
  # here is where we set the pagerduty api requirements
  alert[:incident_key] = results[:hostproblemid]
  alert[:service_key] = results[:contactpager]
  alert[:description] = results[:hostoutput]
  case 
  when results[:notificationtype].match(/PROBLEM/) && results[:hoststate].match(/DOWN/)
    alert[:event_type] = 'trigger'
    Log.info("event_type = #{alert[:event_type]}") if VERBOSE
  when results[:notificationtype].match(/ACKNOWLEDGEMENT/) && results[:hoststate].match(/DOWN/)
    alert[:event_type] = 'acknowledge'
    Log.info("event_type = #{alert[:event_type]}") if VERBOSE
  when results[:notificationtype].match(/RECOVERY/) && results[:hoststate].match(/UP/)
    alert[:event_type] = 'resolve'
    Log.info("event_type = #{alert[:event_type]}") if VERBOSE
  else
    Log.fatal('no event_type detected!')
    Log.info("notificationtype = #{results[:notificationtype]}, hoststate = #{results[:hoststate]}")
    fail ("no event_type detected!")
  end
  alert[:details] = results
  Log.info("this is alertid: " + alert[:incident_key])
else
  check_service_alert(results)
  # here is where we set the pagerduty api requirements
  alert[:incident_key] = results[:serviceproblemid]
  Log.info("this is alertid: " + alert[:incident_key])
  alert[:service_key] = results[:contactpager]
  alert[:description] = [ results[:servicedisplayname] ]
  Log.info("notificationtype = #{results[:notificationtype]}") if VERBOSE
  case 
  when results[:notificationtype].match(/PROBLEM/) && results[:servicestate].match(/CRITICAL/)
    alert[:event_type] = 'trigger'
    if results[:servicenotesurl]
      Log.info('generating a shorter url via google shortenURL api')
      url = results[:servicenotesurl]
      smaller_url = Shorturl.get_url(url)
      Log.info("smaller url is: #{smaller_url}") if VERBOSE
      alert[:description] << smaller_url
    end
    Log.info("event_type = #{alert[:event_type]}") if VERBOSE
  when results[:notificationtype].match(/ACKNOWLEDGEMENT/) && results[:servicestate].match(/CRITICAL/)
    alert[:event_type] = 'acknowledge'
    Log.info("event_type = #{alert[:event_type]}") if VERBOSE
    alert[:description].unshift("ACK")
  when results[:notificationtype].match(/RECOVERY/) && results[:servicestate].match(/OK/)
    alert[:event_type] = 'resolve'
    Log.info("event_type = #{alert[:event_type]}") if VERBOSE
    alert[:description].unshift("OK")
  else
    Log.fatal('no event_type detected!')
    Log.info("notificationtype = #{results[:notificationtype]}, servicestate = #{results[:servicestate]}")
    fail ("no event_type detected!")
  end
  alert[:description].unshift(results[:hostname])
  # and now append the variable text for the error message to the end of the alert description
  alert[:description] << results[:serviceoutput]
  # convert the description array into a string to save space in the message.
  alert[:description] = alert[:description].join(" ")
  alert[:details] = results
  Log.info("this is alertid: " + alert[:incident_key])
end
Log.info('Ready to send to PagerDuty')
Pagerduty.send_to_pagerduty(alert)