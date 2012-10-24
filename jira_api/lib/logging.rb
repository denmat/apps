class Logging

  require 'logger'

  attr_writer :msg

  @log = Logger.new

  def self.info(:msg)
    @log.info(msg)
  end

  def self.warn(:msg)
    @log.warn(msg)
  end

  def self.debug(:msg)
    @log.debug(msg)
  end
end
