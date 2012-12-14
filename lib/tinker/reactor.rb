module Tinker::Reactor
  include Tinker::Evented

  attr_reader :event_queue

  def trap_sigint
    Signal.trap("INT"){ stop }
  end

  def stop
    EventMachine.stop_server @websocket_server
    EventMachine.add_periodic_timer(1){ wait_for_connections_and_stop  }
  end

  def clients
    @clients ||= {}
  end

  def start
    return if @event_queue

    trap_sigint

    @event_queue = Queue.new
    
    @event_thread = Thread.new do
      Thread.current.abort_on_exception = true
      loop do
        event = @event_queue.pop
        puts "Processing event: #{event.inspect}"
        dispatch event
      end
    end
    
    EventMachine.run do
      puts "Starting EventMachine on port #{self.config.port}"

      @websocket_server = EventMachine::WebSocket.start :host => self.config.host, :port => self.config.port do |ws|
        client = Tinker::Client.new(ws)
        clients[ws] = client
        port, ip = Socket.unpack_sockaddr_in(ws.get_peername)

        ws.onopen do
          puts "WebSocket Connection open (#{ip}:#{port})" 

          env = Tinker::Event::Environment.new(:client => client)
          @event_queue.push(Tinker::Event.new :environment => env, :name => "meta.client.join")
        end

        ws.onmessage do |message|
          begin
            params = JSON(message)
            puts "Incoming message (#{ip}:#{port}): #{message}"
            @event_queue.push(Tinker::Event.new :client => client, :name => "client.message")
          rescue JSON::ParserError
            puts "Invalid message (#{ip}:#{port})"
            ws.send({:type => :error, :action => :message, :errors => ["Invalid message format"]}.to_json)
          end
        end

        ws.onclose do
          puts "WebSocket Connection closed (#{ip}:#{port})"

          env = Tinker::Event::Environment.new(:client => client)
          @event_queue.push(Tinker::Event.new :environment => env, :name => "meta.client.leave")
          
          clients.delete ws
        end
      end
    end

    @event_thread.terminate

  end

  private
  def wait_for_connections_and_stop
    if clients.empty?
      EventMachine.stop
      true
    else
      puts "Waiting for #{clients.size} connection(s) to finish"
      false
    end
  end
end