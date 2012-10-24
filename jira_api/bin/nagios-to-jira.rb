#!/usr/bin/env ruby

The pd_nagios_object field must be present.
The NOTIFICATIONTYPE field must be present and must be one of: PROBLEM, ACKNOWLEDGEMENT, RECOVERY, NOP.
The pd_nagios_object field must be present and must be one of: host, service.dmatotek@dmatotek:~/workspace/projects/apps/jira_api/tmp$ ggrep pd_nagios_object pager_duty_sent_CRIT 

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

def nagios_to_json()
  
  data = JSON.parse(notification)
end

def send_restfully(jdata)
  response = RestClient.post 'http://localhost:4567/trigger', { :data => jdata }, {:content_type => :json, :accept => :json}
end

def filter_results(data)

  "LASTSERVICECHECK": "1350608008",
  "SERVICEDISPLAYNAME": "RSYSLOG_QSIZE",
  "LASTSERVICESTATE": "CRITICAL",
  "LASTSERVICECHECK": "1350608008",
  "SERVICESTATEID": "2",
  "SERVICENOTESURL": "https://www.aconex.com/intranet/display/PROD/RSYSLOG_QSIZE+Alert",
  "SERVICEEVENTID": "1918058",
  "SERVICENOTIFICATIONNUMBER": "1",
  "SERVICEPROBLEMID": "933266",
  "SERVICECHECKCOMMAND": "stale_service_is_critical",
  "LASTHOSTCHECK": "1350608002"
  "CONTACTGROUPMEMBERS": "prodoncall,prodtransit,prodlist,pagerduty",
  "CONTACTNAME": "pagerduty",
  "HOSTGROUPNAME": "puppet-prod-host",
  "NOTIFICATIONTYPE": "PROBLEM",
  "HOSTGROUPNAMES": "puppet-prod-host,ops-linux-hosts,ops-hosts-non-us,lhr-servers,has_vpn,dell-servers",
  "CONTACTGROUPNAMES": "prod",
  "MAXHOSTATTEMPTS": "3",
  "SERVICESTATE": "CRITICAL",
  "NOTIFICATIONNUMBER": "1",
  "HOSTNAME": "app1.lhr.acx",
  "LASTHOSTSTATE": "UP"
  "LASTSERVICESTATECHANGE": "1350607771",
  "SERVICEATTEMPT": "15",
  "SERVICEGROUPNAME": "rsyslog_services",
  "LASTSERVICEEVENTID": "1918037",
end
