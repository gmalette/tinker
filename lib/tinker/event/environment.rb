class Tinker::Event::Environment < Hash
  attr_reader :client, :context

  def initialize(params = {})
    @client = params.delete :client
    @context = params.delete :context
    super params
  end
end