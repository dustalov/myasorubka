# encoding: utf-8

require 'logger'

require 'core_ext/enumerable'

# Myasorubka — a morphological dictionaries processor.
#
class Myasorubka
  # Myasorubka version string.
  #
  VERSION = '0.2.0'

  attr_reader :adapter, :path

  # Create a new Myasorubka with given +config+ hash.
  #
  # Important options are: <tt>:adapter</tt> and <tt>:path</tt>.
  # Myasorubka gives to +adapter+ entire +config+ hash
  # without any changes.
  #
  # Basic usage:
  #
  #   config = { :adapter => Myasorubka::AOT }
  #   Myasorubka::Processor.new(config).run!
  #
  def initialize(config = {})
    raise ArgumentError unless @adapter_class = config[:adapter]
    @adapter = @adapter_class.new(config)
    @path = config[:path] || Dir.getwd
  end

  # Executes the adapter with given config.
  #
  def run!
    logger.info 'Started'
    Myaso::TokyoCabinet.new(path, :manage).tap do |myaso|
      myaso.reindex!
      adapter.run! myaso, logger
      myaso.close!
    end
    logger.info 'Finished'
  end

  # Logger instance.
  #
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
