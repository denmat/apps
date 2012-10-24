module Log

  require 'logger'

   @log = Logger.new(STDOUT)

  def self.info(msg)
    @log.info(msg)
  end

  def self.warn(msg)
    @log.warn(msg)
  end

  def self.debug(msg)
    @log.debug(msg)
  end
end
