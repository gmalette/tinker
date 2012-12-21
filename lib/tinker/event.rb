class Tinker::Event
  attr_accessor :environment, :params, :name

  def initialize(name, environment, params = {})
    @name = name
    @environment = environment
    @params = params
  end

  def env
    environment
  end
end