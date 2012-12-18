class Tinker::Client
  attr_reader :socket

  def initialize(socket)
    @socket = socket
    @contexts = Set.new
  end

  def join(context)
    @contexts.add context
  end

  def leave(context)
    @contexts.delete context
  end

  def send(message)
    Tinker.application.message_queue << Tinker::Network::Message.new(:body => message, :socket => socket)
  end

end