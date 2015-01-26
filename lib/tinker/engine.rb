class Tinker::Engine
  include Singleton
  include Tinker::Context

  attr_accessor :config

  def initialize
    super
  end

  def self.configure
    @singleton__mutex__.synchronize {
      app = self.send(:allocate)
      app.config = Configuration.new
      yield app.config if block_given?
      @singleton__instance__ = app
    }
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
        port: "6202",
        host: "0.0.0.0"
      }.each do |k, v|
        self.send("#{k}=", v)
      end
    end
  end
end
