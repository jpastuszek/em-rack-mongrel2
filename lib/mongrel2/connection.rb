require 'em-zeromq'
require 'mongrel2/request'
require 'mongrel2/response'

module Mongrel2
  class Connection
    attr_reader :received
    @context = nil

    def self.context
      @context ||= EM::ZeroMQ::Context.new(1)
    end

    def initialize(uuid, sub, pub, app)
      @uuid, @sub, @pub, @app = uuid, sub, pub, app

      # Connect to receive requests
      @reqs = self.class.context.connect(ZMQ::PULL, sub, self)

      # Connect to send responses
      @resp = self.class.context.connect(ZMQ::PUB, pub, nil, :identity => uuid)
    end

    def on_readable(socket, messages)
      messages.each do |msg|
        req = msg.nil? ? nil : Request.parse(msg.copy_out_string, self)
        next if req.nil? || req.disconnect?
        process req
      end
    end

    def process(req)
      pre = Proc.new do
        method(:pre_process).call(req)
      end

      post = Proc.new do |resp|
        method(:post_process).call(resp, req)
      end

      EM.defer pre, post
    end

    def pre_process(req)
      status, headers, rack_response = -1, {}, []

      catch(:async) do
        status, headers, rack_response = @app.call(req.env)
      end

      [status, headers, rack_response]
    end

    def post_process(response, req)
      status, headers, rack_response = *response
      # Status code -1 indicates that we're going to respond later (async).
      return if -1 == status

      body = ''
      rack_response.each { |b| body << b }
      reply req, body, status, headers
    end

    def reply(req, body, status = 200, headers = {})
      resp = Response.new(@resp)
      resp.send_http req, body, status, headers
      resp.close req if req.close?
    end

    def close
      # I think I should be able to just close the context
      self.class.context.close rescue nil
    end
  end
end
