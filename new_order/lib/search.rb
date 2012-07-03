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
          sumname = Search.md5(fname)
          sumfile = Search.md5(fname, fsize)
          unless redis.exists("#{sumname}.#{sumfile}")
            redis.rpush("#{sumname}.#{sumfile}", [ fname, pdir ])
          else 
            redis.rpush("#{sumname}.#{sumfile}", [ fname, pdir ])
          end
        end
      end
    end
  end

  def self.md5(*blob)
    if blob.class.to_s == 'Array'
      sum = blob.join(',')
    else
      sum = blob
    end
    Digest::MD5::hexdigest(sum)
  end

  def self.find_dups(redis_connection)
    redis = redis_connection
    keys = redis.keys('*')
    keys.each do |k|
      puts "doing #{k}"
      length = redis.llen(k)
      if length > 2
          puts "creating array"
          dup = Array.new
        while length > 0
          puts "getting #{k}"
          dup = redis.lpop(k)
          puts dup
        end
      end
    end
  end  
end
