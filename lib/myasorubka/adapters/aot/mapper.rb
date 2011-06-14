# encoding: utf-8

class Myasorubka::AOT::Mapper
  attr_reader :url, :id

  def initialize(url, id)
    @url, @id = url, id
  end

  def run!
    loop do
      socket.send_string('test')
      p socket.recv_multipart
      sleep 1
    end
    socket.close
    zctx.close
  end

  private
    def zctx
      @zctx ||= ZMQ::Context.new
    end

    def socket
      @socket ||= zctx.socket(ZMQ::REQ).tap do |req|
        req.setsockopt(ZMQ::IDENTITY, id)
        req.connect(url)
      end
    end
end
