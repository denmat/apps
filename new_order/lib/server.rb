require 'rubygems'
require 'redis'

module Server

  def self.redis(redis_host='127.0.0.1', redis_port='6379')
    host = redis_host
    port = redis_port

    redis = Redis.new(:host => host, :port => port)
  end

end
