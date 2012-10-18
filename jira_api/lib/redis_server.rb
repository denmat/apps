require 'rubygems'
require 'redis'

module Redis_Server

  def self.redis(redis_host='127.0.0.1', redis_port='6379')

    redis = Redis.new(:host => host, :port => port)
    
  end

end