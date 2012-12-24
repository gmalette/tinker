require 'spec_helper'
require 'tempfile'

require 'pry'
class MockSocket 
  attr_reader :file

  def initialize
    @file = Tempfile.new("socket")
  end

  def send(params)
    @file.write(params.to_json)
  end
end


shared_examples "a context" do
  
  context "#add_client" do
    before {
      context.add_client(client_1)
    }

    it "sends a 'meta.context.join' message" do
      client_1.socket.file.rewind
      message = JSON(client_1.socket.file.read)
      message['action'].should == 'meta.context.join'
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