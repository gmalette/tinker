class Tinker::Application < Tinker::Engine
  include Tinker::Reactor

  on "meta.client.join", :on_client_join
  on "meta.client.leave", :on_client_leave

  def initialize
    super
    Tinker.application ||= self
  end

  def on_client_join(event)
    add_client(event.environment.client)
  end

  def on_client_leave(event)
    event.environment.client.disconnect
  end
end
