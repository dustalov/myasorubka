# encoding: utf-8

require 'logger'

# Processor is a core of Myasorubka. This class prepares the environment
# and starts the processing adapter.
#
# Basic usage:
#
#   configuration = { :adapter => Myasorubka::AOT }
#   Myasorubka::Processor.new(configuration).run!
#
class Myasorubka::Processor
  attr_reader :adapter, :path

  # Create a new Processor with given +configuration+ hash.
  #
  # Important options are: <tt>:adapter</tt> and <tt>:path</tt>.
  # Processor gives to +adapter+ entire +configuration+ hash
  # without any changes.
  #
  def initialize(configuration = {})
    raise ArgumentError unless @adapter_class = configuration[:adapter]
    @adapter = @adapter_class.new(configuration)
    @path = configuration[:path] || Dir.getwd
  end

  # Executes the adapter with given configuration.
  #
  def run!
    logger.info 'Started'
    Myaso::Database.new(Dir.getwd, :manage).tap do |db|
      db.reindex
      adapter.run! db, logger
      db.close!
    end
    logger.info 'Finished'
  end

  # Logger instance.
  #
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
