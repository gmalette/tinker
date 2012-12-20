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
      self.class.contexts[@id] = self
      super
    end


    # Public: Removes this context from accessible contexts
    #
    #
    # Examples
    #
    #     @room.release
    # 
    # Returns self
    def release
      @roster.each do |client|
        remove_client(client)
      end

      self.class.contexts.delete @id
      self
    end

    # Public: Sends the message to all connected clients of this room
    #
    # message - The message to send to the clients
    #
    # Examples
    #
    #     @room.broadcast({:chat => "message"})
    #
    # Returns self
    def broadcast(message)
      @roster.each{ |client| client.send(message) }
      self
    end

    # Public: Adds a client to the roster
    #
    # client - The client to add to the roster
    #
    # Examples
    #
    #     @room.add_client(client)
    #
    # Returns self
    def add_client(client)
      @roster.add client
      client.join(self)

      env = Tinker::Event::Environment.new :context => self, :client => client
      dispatch Tinker::Event.new(:environment => env, :name => "client.join")
      self
    end

    # Public: Removes a client from the roster
    #
    # client - The client to remove
    #
    # Examples
    #
    #     @room.remove_client(client)
    #
    # Returns self
    def remove_client(client)
      @roster.delete client
      client.leave(self)

      env = Tinker::Event::Environment.new :context => self, :client => client
      dispatch Tinker::Event.new(:environment => env, :name => "client.leave")
      self
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
    def contexts
      @contexts ||= {}
    end

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
