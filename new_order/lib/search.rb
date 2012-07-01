$:.unshift File.dirname(__FILE__)

# This program sort through file directories and finds matching files

require 'find'
require 'md5'
require 'rubygems'
require 'redis'
require 'json'
require 'yaml'
require 'server'

module Search

  def self.find_file(path,redis_connection)
    redis = redis_connection 

    Find.find(path) do |p|
      if FileTest.directory?(p)
        if File.basename(p)[0] == 46
          Find.prune
        else
          next
        end
      else
        unless FileTest.symlink?(p) 
          fdate = File.stat(p).ctime
          fsize = File.stat(p).size
          pdir  = File.dirname(p)
          fname = File.basename(p) 
          unless redis.exists(fname)
            redis.rpush(fname, [ Search.md5(fname, fsize), pdir ].to_json)
          else 
            redis.rpush(fname, [ Search.md5(fname, fsize), pdir ].to_json)
          end
        end
      end
    end
  end

  def self.md5(*blob)
    Digest::MD5::hexdigest(blob.join(','))
  end

  def self.find_dups
  end  
end
