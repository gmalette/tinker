class Tinker::Engine
  include Tinker::Context

  attr_reader :config

  def initialize
    super
    @config = Configuration.new
    self.class.instance = self
  end

  def self.configure
    app = self.instance
    yield app.config if block_given?
    app
  end

  class << self
    def instance
      @instance || self.new
    end

    def instance=(instance)
      @instance = instance
    end
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