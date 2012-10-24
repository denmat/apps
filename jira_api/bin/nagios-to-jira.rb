#!/usr/bin/env ruby


# This script is triggered by cron and grabs the details of the nagios alert and send it to the 
# local sinatra server.

require 'optparse'
require 'json'

include Log
include PagerDuty

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
    SERVICEDISPLAYNAME =ENV['SERVICEDISPLAYNAME']
    LASTSERVICECHECK = ENV["LASTSERVICECHECK"]
    SERVICEDISPLAYNAME = ENV["SERVICEDISPLAYNAME" ]
    LASTSERVICESTATE = ENV["LASTSERVICESTATE"]
    LASTSERVICECHECK = ENV["LASTSERVICECHECK"]
    SERVICESTATEID = ENV["SERVICESTATEID"]
    SERVICENOTESURL = ENV["SERVICENOTESURL"]
    SERVICEEVENTID = ENV["SERVICEEVENTID"]
    SERVICENOTIFICATIONNUMBER = ENV["SERVICENOTIFICATIONNUMBER"]
    SERVICEPROBLEMID = ENV["SERVICEPROBLEMID"]
    SERVICECHECKCOMMAND = ENV["SERVICECHECKCOMMAND"]
    LASTHOSTCHECK = ENV["LASTHOSTCHECK"]
    CONTACTGROUPMEMBERS = ENV["CONTACTGROUPMEMBERS"]
    CONTACTNAME = ENV["CONTACTNAME"]
    HOSTGROUPNAME = ENV["HOSTGROUPNAME"]
    NOTIFICATIONTYPE = ENV["NOTIFICATIONTYPE"]
    HOSTGROUPNAMES = ENV["HOSTGROUPNAMES"]
    CONTACTGROUPNAMES = ENV["CONTACTGROUPNAMES"]
    MAXHOSTATTEMPTS = ENV["MAXHOSTATTEMPTS"]
    SERVICESTATE = ENV["SERVICESTATE"]
    NOTIFICATIONNUMBER = ENV["NOTIFICATIONNUMBER"]
    HOSTNAME = ENV["HOSTNAME"]
    LASTHOSTSTATE = ENV["LASTHOSTSTATE"] 
    LASTSERVICESTATECHANGE = ENV["LASTSERVICESTATECHANGE"]
    SERVICEATTEMPT = ENV["SERVICEATTEMPT"]
    SERVICEGROUPNAME = ENV["SERVICEGROUPNAME"]
    LASTSERVICEEVENTID = ENV["LASTSERVICEEVENTID"]
  end
end