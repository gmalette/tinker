require 'thin-em-websocket'
require 'tinker'

module Tinker
  class Middleware
    def initialize(next_app, tinker_app: )
      @next_app = next_app
      @tinker_app = nil
      EventMachine.schedule do
        @tinker_app = tinker_app

        @tinker_app.prepare
      end
    end

    def call(env)
      connection = env['em.connection']
      if connection && connection.websocket?
        return unless env['PATH_INFO'] == '/'
        puts "upgrading web socket"
        connection.upgrade_websocket

        if @tinker_app
          @tinker_app.connect(connection)
          return Thin::Connection::AsyncResponse
        end
      else
        @next_app.call(env)
      end
    end
  end
end

