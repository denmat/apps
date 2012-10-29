module Shorturl

require 'rest-client'
require 'json'

  CONF_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "conf"))
  CONFIG = JSON.parse(File.read(CONF_DIR + '/pagerduty.json'))
  GOOGLE_URL_SHORTNER = CONFIG['GOOGLE_URL_SHORTNER']

  def get_url(url)
    jdata = { "longUrl" => url }
    res = RestClient.post GOOGLE_URL_SHORTNER, jdata.to_json, :content_type => :json, :accept => :json
    result = JSON.parse(res)
    unless result['id'].match(/goo.gl/)
      Log.info("Shorter URL id, #{result['id']}") if VERBOSE
      Log.warn("Could not generate the small url via google api.")
    else 
      Log.info("Shorter URL generated, #{result['id']}") if VERBOSE
      return result['id']
    end
  end
end