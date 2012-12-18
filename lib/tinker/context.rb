module Tinker::Context
  include Tinker::Evented

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module InstanceMethods
    attr_reader :roster, :id

    def initialize
      @id = SecureRandom.uuid
      @roster = Set.new
      
      initialize_listeners
      super
    end

    def broadcast(message)
      @roster.each{ |client| client.send(message) }
      self
    end

    def add_client(client)
      @roster.add client
      client.join(self)

      env = Tinker::Event::Environment.new :context => self, :client => client
      dispatch Tinker::Event.new(:environment => env, :name => "client.join")
    end

    def remove_client(client)
      @roster.delete client
      client.leave(self)

      env = Tinker::Event::Environment.new :context => self, :client => client
      dispatch Tinker::Event.new(:environment => env, :name => "client.leave")
    end

    def dispatch(event)
      event.environment = Tinker::Event::Environment.new(:client => event.environment.client, :context => self)
      super(event)
    end

    private
    def initialize_listeners
      self.class.ancestors_binding_definitions.each do |name, args|
        on name, *args
      end
    end
  end

  module ClassMethods
    def binding_definitions
      @binding_definitions ||= []
    end

    def ancestors_binding_definitions
      ancestors.select{|klass| klass < Tinker::Context}.reduce([]){|arr, klass| arr.push *klass.binding_definitions }
    end
  
    def on event_name, *args
      binding_definitions << [event_name, *args]
    end
  end

end
