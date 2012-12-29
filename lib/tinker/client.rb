class Tinker::Client
  attr_reader :socket, :id

  def initialize(socket)
    @socket = socket
    @id = SecureRandom.uuid
    @contexts = Set.new
  end

  def join(context)
    @contexts.add context
    send(:action => "meta.context.join", :context => context.id, :params => {:type => context.class})
  end

  def leave(context)
    @contexts.delete context
    send(:action => "meta.context.leave", :context => context.id, :params => {:type => context.class})
  end

  def send(params)
    socket.send(params)
  end

end