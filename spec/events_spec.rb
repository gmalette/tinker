require 'spec_helper'

shared_examples "a callback" do
  before { context.on "event", callback }

  it "sends the event" do
    event = Tinker::Event.new("event", Tinker::Event::Environment.new(nil, context))
    callback.should_receive(:call).with(event)
    context.dispatch(event)
  end
end

describe "Evented" do
  class Tester
    def call(*params)
    end
  end

  let(:context) { Tinker::Room.new }

  context "with a Proc" do
    let(:callback) { Proc.new{} }

    it_behaves_like "a callback"
  end

  context "with a class instance" do
    let(:callback) { Tester.new }

    it_behaves_like "a callback"
  end

  context "with a class" do
    let(:callback) { Tester }

    it_behaves_like "a callback"
  end
end