require 'spec_helper'

require 'pry'
class MockSocket 
  attr_reader :messages

  def initialize
    @messages = []
  end

  def send(params)
    messages << params
  end
end


shared_examples "a context" do
  
  context "#add_client" do
    before {
      context.add_client(client_1)
      context.add_client(client_2)
    }

    it "adds the client to the roster" do
      context.roster.should include(client_1)
    end

    it "sends a 'meta.context.join' message" do
      message = client_1.socket.messages.first
      message[:action].should == 'meta.context.join'
    end

    it "sends the event to other clients" do
      message = client_1.socket.messages.last
      message[:action].should == 'meta.roster.add'
      message[:params][:id].should == client_2.id
    end

    it "doesn't send the event to self" do
      client_2.socket.messages.each do |message|
        if message[:action] == 'meta.roster.add'
          message[:params][:id].should_not == client_2.id
        end
      end
    end
  end

  context "#send_to_client" do
    before {
      context.send_to_client(client_1, :action => :test, :params => {})
    }

    it "sends the message to the client"  do
      client_1.socket.messages.last[:action].should == :test
    end
  end

  context "#remove_client" do
    before {
      context.add_client(client_1)
      context.add_client(client_2)

      context.remove_client(client_1)
    }

    it "removes the client from the roster" do
      context.roster.should_not include(client_1)
    end

    it "sends a message to the removed client" do
      client_1.socket.messages.last[:action].should == "meta.context.leave"
    end

    it "sends a message to the other clients" do
      client_2.socket.messages.last[:action].should == "meta.roster.remove"
    end
  end

  context "#release" do
    before {
      context.add_client(client_1)
      context.release
    }

    it "removes itself from the global roster" do
      Tinker::Context.contexts.should_not include(context)
    end

    it "disconnects all clients" do
      client_1.socket.messages.last[:action].should == "meta.context.leave"
    end
  end

  context "#broadcast" do
    let(:message) { {:action => "test.broadcast", :params => {}, :context => context.id, :reply_to => nil } }

    before {
      context.add_client(client_1)
      context.add_client(client_2)
      context.broadcast(message)
    }

    it "sends the message to all clients" do
      client_1.socket.messages.last.should == message
      client_2.socket.messages.last.should == message
    end
  end
end



describe "Context" do
  let(:socket_1) { MockSocket.new }
  let(:client_1) { Tinker::Client.new(socket_1) }

  let(:socket_2) { MockSocket.new }
  let(:client_2) { Tinker::Client.new(socket_2) }

  context "Room" do
    let(:context) { Tinker::Room.new }

    it_behaves_like "a context"
  end

  context "Application" do
    before { Tinker::Application.release_singleton }
    let(:context) { Tinker::Application.instance }

    it_behaves_like "a context"
  end
end