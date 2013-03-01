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
    # options:
    #   - except => list of clients to whom the message will not be sent
    # Returns self
    def broadcast(params)
      except = Array(params.delete(:except)) || []
      @roster.each{ |client| self.send_to_client(client, params) unless except.include?(client) }
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

      broadcast(:action => "meta.roster.add", :params => {:id => client.id}, :except => client)

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

      broadcast(:action => "meta.roster.remove", :params => {:id => client.id}, :except => client)

      self
    end

    def send_to_client(client, reply_to = nil, params)
      params = params.dup.merge({:context => @id, :reply_to => reply_to})
      client.send(params)
    end

    
    def dispatch(event)
      event.environment = Tinker::Event::Environment.new(event.environment.client, self)
      super(event)
    end

    private
    def initialize_listeners
      self.class.ancestors_binding_definitions.each do |block|
        self.instance_eval &block
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
    
    %w(on every).each do |m|
      define_method(m.to_sym) do |*args, &block|
        args << block if block
        binding_definitions.push(Proc.new{
          self.send(m, *args)
        })
      end
    end

  end
end
