require 'spec_helper'
require 'tempfile'

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

    it "sends a 'meta.context.join' message" do
      message = client_1.socket.messages.first
      message[:action].should == 'meta.context.join'
    end

    it "adds the client to the roster" do
      context.roster.should include(client_1)
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

  it "#send_to_client"

  it "#remove_client"

  it "#release"

  it "#broadcast"
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
    let(:context) { Tinker::Application.instance }

    it_behaves_like "a context"
  end
end