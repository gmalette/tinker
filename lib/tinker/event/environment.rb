class Tinker::Event::Environment < Hash
  attr_reader :client, :context

  def initialize(client, context, params = {})
    @client = client
    @context = context
    super params
  end
end