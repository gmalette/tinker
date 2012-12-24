class Tinker::Client
  attr_reader :socket

  def initialize(socket)
    @socket = socket
    @contexts = Set.new
  end

  def join(context)
    @contexts.add context
    send(:action => "meta.context.join", :context => context.id, :type => context.class)
  end

  def leave(context)
    @contexts.delete context
    send(:action => "meta.context.leave", :context => context.id, :type => context.class)
  end

  def send(params)
    socket.send(params)
  end

end