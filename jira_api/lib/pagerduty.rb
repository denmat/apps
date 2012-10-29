module Pagerduty

  require 'rest_client'
  require 'json'

  include Log

  CONF_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "conf"))
  CONFIG = JSON.parse(File.read(CONF_DIR + '/pagerduty.json'))
  PAGERDUTY_QUERY_API_KEY = CONFIG['PAGERDUTY_QUERY_API_KEY']
  PAGERDUTY_QUERY_API = CONFIG['PAGERDUTY_QUERY_API']
  PAGERDUTY_INCIDENTS_API = CONFIG['PAGERDUTY_INCIDENTS_API']
  # this is not the key that is used to trigger alerts, but used to generally query the API
  INCIDENT_QUERY_URL = PAGERDUTY_QUERY_API + ', ' + ':authorization => "Token token=#{PAGERDUTY_QUERY_API_KEY}", :content_type => :json, :accept => :json'

#  def initialize(jdata, problemid, alert_api_key)
#    @jdata = jdata
#    @problemid = problemid
#    @alert_api_key = alert_api_key
#  end

  # this triggers and updates the alerts from nagios -> pagerduty
  def send_to_pagerduty(alert)
  # This creates and updates alerts from nagios.
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


    @jdata = alert.to_json
    Log.info("going to send: #{JSON.pretty_generate(JSON.parse(@jdata))}") if VERBOSE
    Log.info("connecting to #{PAGERDUTY_INCIDENTS_API}")

    res = RestClient.post PAGERDUTY_INCIDENTS_API, @jdata, :content_type => :json, :accept => :json
    result = JSON.parse(res)
    unless result['status'] == 'success'
      Log.fatal("Failure to send data to pagerduty, result: #{result['status']}")
      Log.fatal("Message response: #{result['message']}")
      fail("Could not send to Pagerduty, result: #{result['status']}")
    else 
      Log.info("Pagerduty status: #{result['status']}")
      Log.info("Pagerduty incident_key: #{result['incident_key']}")
      Log.info("Pagerduty message: #{result['message']}") if VERBOSE
    end
  end

  # this gets the details of the alert via the nagios problemid
  def get_incident_by_problemid(problemid)
    # use problemid from nagios as a filter passed as incident_key
    res = RestClient.get INCIDENT_QUERY_URL, :params => {:fields => "#{problemid}"} 
  end

  # get a list of ack'd incidents
  def get_ack_incidents
  # use status of incident as a filter
    res = RestClient.get INCIDENT_QUERY_URL, :params => { :status => "acknowledged", :fields => "incident_number" }
  end

  # get a list of resolved incidents
  def get_resolved_incidents
  # use status of incident as a filter
    res = RestClient.get INCIDENT_QUERY_URL, :params => { :status => "resolved", :fields => "incident_number" }
  end

  # get a list of current triggered incidents
  def get_triggered_incidents
  # use status of incident as a filter
    res = RestClient.get INCIDENT_QUERY_URL, :params => { :status => "triggered", :fields => "incident_number" }
  end

end