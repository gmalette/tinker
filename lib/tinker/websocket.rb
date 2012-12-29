class Tinker::WebSocket
  attr_reader :socket
  
  def initialize(websocket)
    @socket = websocket
  end

  def send(params)
    message = params.to_json
    Tinker.application.message_queue << Tinker::Network::Message.new(:body => message, :socket => socket)
  end
end