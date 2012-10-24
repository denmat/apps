class Pagerduty

  require 'rest_client'
  require 'json'

  include Log

  PAGERDUTY_QUERY_API = "https://s0saconex.pagerduty.com/api/v1/incidents"
  PAGERDUTY_INCIDENTS_API = "https://events.pagerduty.com/generic/2010-04-15/create_event.json"
  # this is not the key that is used to trigger alerts, but used to generally query the API
  PAGERDUTY_QUERY_API_KEY = JSON.parse(File.read('../conf/pagerduty.json'))['PAGERDUTY_QUERY_API_KEY']
  INCIDENT_QUERY_URL = PAGERDUTY_QUERY_API + ', ' + ':authorization => "Token token=#{PAGERDUTY_QUERY_API_KEY}"'

  def initialize(jdata, problemid, alert_api_key)
    @jdata = jdata
    @problemid = problemid
    @alert_api_key = alert_api_key
  end

  # this triggers and updates the alerts from nagios -> pagerduty
  def send_to_pagerduty
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
    Log.info("connecting to #{PAGERDUTY_INCIDENTS_API}")
    res = RestClient.post PAGERDUTY_INCIDENTS_API, @jdata, :content_type => :json, :accept => :json
      unless res.match(/Event Processed/)
        Log.info("Failure to send data to pagerduty: result: #{res}")
        Log.debug("res: #{res}\n#{@jdata}") if DEBUG
      end
  end

  # this gets the details of the alert via the nagios problemid
  def get_incident_by_problemid
    # use problemid from nagios as a filter passed as incident_key

  end

  # get a list of ack'd incidents
  def get_ack_incidents
  # use status of incident as a filter    

  end

  # get a list of resolved incidents
  def get_resolved_incidents
  # use status of incident as a filter
  end

  # get a list of current triggered incidents
  def get_triggered_incidents
  # use status of incident as a filter

  end

# create nagios event
end