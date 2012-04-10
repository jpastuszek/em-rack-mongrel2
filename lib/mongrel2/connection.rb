module Mongrel2
  class Connection
    attr_reader :chroot
    @context = nil

    def self.context
       @context ||= EM::ZeroMQ::Context.new(1)
    end

    def initialize(uuid, sub, pub, chroot, app)
      @uuid, @sub, @pub, @chroot, @app = uuid, sub, pub, chroot, app

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

      resp = Response.new(@resp)

      begin
        resp.send_http_header req, status, headers

        rack_response.each do |b|
          resp.send_http_data req, b
        end
      ensure
        if rack_response.respond_to? :callback
          rack_response.callback do
            resp.close(req)
          end 
        else
          resp.close(req)
          rack_response.close if rack_response.respond_to? :close
        end
      end
    end

    def close
      # I think I should be able to just close the context
      self.class.context.close rescue nil
    end
  end
end
