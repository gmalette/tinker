require 'tinker'

module Tinker
  class Standalone
    def initialize(tinker_app)
      @tinker_app = tinker_app
    end

    def run
      EventMachine.run do
        @tinker_app.prepare
        puts "Starting EventMachine on port #{@tinker_app.config.port}"
        @websocket_server = EventMachine::start_server(@tinker_app.config.host, @tinker_app.config.port, EventMachine::WebSocket::Connection, {}) do |ws|
          @tinker_app.connect(ws)
        end
      end
      @tinker_app.kill
    end
  end
end
