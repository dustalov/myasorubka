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
  INPROC_SOCKET = 'inproc://myasorubka'

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

    #raise ArgumentError unless @parser_class = configuration[:parser]
    #raise ArgumentError unless @mapper_class = configuration[:mapper]

    #@parser = @parser_class.new(configuration)
  end

  # Executes the adapter with given configuration.
  #
  def run!
    #logger.info 'Starting ØMQ inter-thread communication with DB'
    #database_thread = Thread.new(&method(:database).to_proc)
    #sleep 1

    db = Myaso::Database.new(Dir.getwd, :manage)

    adapter.run! db, logger

    db.close!

    #push.send_multipart(['done'])
    #push.close

    #database_thread.join
    #zctx.terminate
  end

  def database
    logger.info 'Database thread started'

    pull = zctx.socket(ZMQ::PULL)
    pull.bind(INPROC_SOCKET)

    db = Myaso::Database.new(Dir.getwd, :manage)
    loop do
      begin
        cmd, *args = pull.recv_multipart.map do |s|
          s.force_encoding('UTF-8')
        end

        case cmd
        when 'insert' then begin
          table_name, id, *data_array = args

          table = table_name.to_sym
          data = Hash[*data_array]

          db.send(table).put(id, data)
        end
        when 'done' then break
        else raise ArgumentError, "unknown command '#{cmd}'"
        end
      rescue Interrupt
        break
      end
    end
    db.close!

    pull.close

    logger.info 'Database thread stopped'
  end

  def zctx
    @zctx ||= ZMQ::Context.new
  end

  def push
    @push ||= zctx.socket(ZMQ::PUSH).tap do |push|
      push.connect(INPROC_SOCKET)
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
