module Tinker::Context
  include Tinker::Evented

  class << self
    def contexts
      @contexts ||= {}
    end
  end

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
      Tinker::Context.contexts[@id] = self
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

      Tinker::Context.contexts.delete @id
      self
    end

    # Public: Sends the message to all connected clients of this room
    #
    # params - The message to send to the clients
    #
    # Examples
    #
    #     @room.broadcast({:chat => "message"})
    #
    # Returns self
    def broadcast(params)
      @roster.each{ |client| self.send_to_client(client, params) }
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
      @roster.add(client)
      client.join(self)

      env = Tinker::Event::Environment.new(client, self)
      dispatch Tinker::Event.new("client.join", env)
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

      env = Tinker::Event::Environment.new(client, self)
      dispatch Tinker::Event.new("client.leave", env)
      self
    end

    def send_to_client(client, reply_to = nil, params)
      client.send({:context => @id, :params => params, :reply_to => reply_to})
    end

    
    def dispatch(event)
      event.environment = Tinker::Event::Environment.new(event.environment.client, self)
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
