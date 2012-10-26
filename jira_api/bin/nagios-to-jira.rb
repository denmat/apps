#!/usr/bin/env ruby


# This script is triggered by cron and grabs the details of the nagios alert and send it to the 
# local sinatra server.

require 'optparse'
require 'json'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))

require 'log'
require 'pagerduty'

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

  def filter_alert_results()
    results = Hash.new

    results[:contactpager]  = ENV["CONTACTPAGER"]
    results[:serviceproblemid]  = ENV["SERVICEPROBLEMID"]
    results[:serviceoutput]  = ENV["SERVICEOUTPUT"]
    results[:lastservicecheck]  = ENV["LASTSERVICECHECK"]
    results[:servicedisplayname]  = ENV["SERVICEDISPLAYNAME" ]
    results[:lastservicestate]  = ENV["LASTSERVICESTATE"]
    results[:servicestateid]  = ENV["SERVICESTATEID"]
    results[:servicenoteurl]  = ENV["SERVICENOTESURL"]
    results[:servciceeventid]  = ENV["SERVICEEVENTID"]
    results[:servicenotificationnumber]  = ENV["SERVICENOTIFICATIONNUMBER"]
    results[:servicecheckcommand]  = ENV["SERVICECHECKCOMMAND"]
    results[:losthostcheck]  = ENV["LASTHOSTCHECK"]
    results[:contactgroupmembers]  = ENV["CONTACTGROUPMEMBERS"]
    results[:contactname]  = ENV["CONTACTNAME"]
    results[:hostgroupname]  = ENV["HOSTGROUPNAME"]
    results[:notificationtype]  = ENV["NOTIFICATIONTYPE"]
    results[:hostgroupnames]  = ENV["HOSTGROUPNAMES"]
    results[:contactgroupnames]  = ENV["CONTACTGROUPNAMES"]
    results[:maxhostattempts]  = ENV["MAXHOSTATTEMPTS"]
    results[:servicestate]  = ENV["SERVICESTATE"]
    results[:notificationnumber]  = ENV["NOTIFICATIONNUMBER"]
    results[:hostname]  = ENV["HOSTNAME"]
    results[:lasthoststate] = ENV["LASTHOSTSTATE"]
    results[:lastservicechange]  = ENV["LASTSERVICESTATECHANGE"]
    results[:serviceattempt]  = ENV["SERVICEATTEMPT"]
    results[:servicegroupname]  = ENV["SERVICEGROUPNAME"]
    results[:lastserviceeventid]  = ENV["LASTSERVICEEVENTID"]

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
  puts "this is alertid: " + alert[:problemid]
else
  check_service_alert(alert)
  alert[:problemid] = alert[:serviceproblemid]
  puts "this is alertid: " + alert[:problemid]
end