class Tinker::Application < Tinker::Engine
  include Tinker::Reactor

  on "meta.client.join", :on_client_join

  def initialize
    super
    Tinker.application ||= self
  end

  def on_client_join(event)
    add_client(client)
  end
end