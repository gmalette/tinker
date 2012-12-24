class Tinker::Engine
  include Singleton
  include Tinker::Context

  attr_reader :config

  def initialize
    super
    @config = Configuration.new
  end

  def self.configure
    app = self.instance
    yield app.config if block_given?
    app
  end

  def self.release_singleton
    @singleton__mutex__.synchronize {
      @singleton__instance__ = nil
    }
    self
  end

  class Configuration
  	attr_accessor :port, :host

    def initialize
      {
        :port => "6202",
        :host => "0.0.0.0"
      }.each do |k, v|
        self.send("#{k}=", v)
      end
    end
  end
end