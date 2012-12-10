EventMachine.run do
  puts "AMQP Connected with version #{AMQP::VERSION}"

  AMQP.connection = AMQP.connect(:host => '127.0.0.1')

  room = Room.new
  room.on :authenticate, Authenticator
  room.on :heartbeat, Heartbeat
  room.on :chat, Chat
  room.on :move, Move, PositionReport

  puts "Starting EventMachine on port #{Choice.choices[:port]}"

  EventMachine::WebSocket.start :host => "0.0.0.0", :port => Choice.choices[:port] do |ws|
    room.bind(ws)
  end
end