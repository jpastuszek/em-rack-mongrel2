require 'mongrel2/connection'
require 'stringio'
require 'eventmachine'

module Rack
  module Handler
    class Mongrel2
      class << self
        def run(app, options = {})
          options = {
            :recv => ENV['RACK_MONGREL2_RECV'] || 'tcp://127.0.0.1:9997',
            :send => ENV['RACK_MONGREL2_SEND'] || 'tcp://127.0.0.1:9996',
            :uuid => ENV['RACK_MONGREL2_UUID']
          }.merge(options)

          raise ArgumentError.new('Must specify an :uuid or set RACK_MONGREL2_UUID') if options[:uuid].nil?

          conn = nil

          EM.run do
            conn = ::Mongrel2::Connection.new(options[:uuid], options[:recv], options[:send], app)
            
            # This doesn't work at all until zmq fixes their shit (in 2.1.x I think), but trap it now anyway.
            %w(INT TERM KILL).each do |sig|
              trap(sig) do
                conn.close
                EM.stop
              end
            end
          end
        ensure
          conn.close if conn.respond_to?(:close)
        end
      end
    end
  end
end
