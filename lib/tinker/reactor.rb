module Tinker::Reactor
  include Tinker::Evented

  attr_reader :event_queue, :message_queue

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

  def prepare
    return if @event_queue

    trap_sigint

    @event_queue = Queue.new
    @message_queue = Queue.new

    @event_thread = Thread.new do
      Thread.current.abort_on_exception = true
      loop do
        event = @event_queue.pop
        # puts "Processing event: #{event.inspect}"
        event.env.context.dispatch event
      end
    end

    @message_thread = Thread.new do
      Thread.current.abort_on_exception = true
      loop do
        message = @message_queue.pop
        # puts "Sending message: #{message.inspect}"
        message.socket.send(message.body)
      end
    end

    Backro::Application.instance.send(:initialize)
  end

  def connect(ws)
    websocket = Tinker::WebSocket.new(ws)

    client = Tinker::Client.new(websocket)
    clients[ws] = client

    ws.onopen do
      puts "WebSocket Connection open"

      env = Tinker::Event::Environment.new(client, Tinker.application)
      @event_queue.push(Tinker::Event.new("meta.client.join", env))
    end

    ws.onmessage do |message|
      begin
        # puts "Incoming message: #{message}"
        json = JSON(message)

        env = Tinker::Event::Environment.new(client, (Tinker::Context.contexts[json['context']] || Tinker.application))
        event = Tinker::Event.new("client.message.#{json['action']}", env, json['params'])

        @event_queue.push(event)
      rescue JSON::ParserError
        # puts "Invalid message"
        ws.send({:type => :error, :action => :message, :errors => ["Invalid message format"]}.to_json)
      end
    end

    ws.onclose do
      puts "WebSocket Connection closed"

      env = Tinker::Event::Environment.new(client, Tinker.application)
      @event_queue.push(Tinker::Event.new("meta.client.leave", env))

      clients.delete ws
    end
  end

  def kill
    @event_thread.terminate
    @message_thread.terminate
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
