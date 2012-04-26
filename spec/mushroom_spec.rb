require "spec_helper"

describe Mushroom do
  class Server
    include Mushroom

    def start
      notify :start
    end

    def stop
      sleep 0.1
    end
    instrument :stop
  end

  let(:server) { Server.new }

  describe '.event_name' do
    it 'constructs a valid event name from class and event triggered' do
      server = Server.new

      Mushroom.event_name(:start, server).should == 'server:start'
    end

    it 'works with a string' do
      Mushroom.event_name(:start, 'server').should == 'server:start'
    end

    it 'works with a class' do
      Mushroom.event_name(:start, Server).should == 'server:start'
    end
  end

  describe 'Server' do
    describe '#start' do
      it 'triggers a server:start event' do
        ActiveSupport::Notifications.should_receive(:instrument).with("server:start", {:target=>server, :args=>[]}).once
        server.start
      end
    end

    describe '#stop' do
      it 'triggers a server:stop event' do
        ActiveSupport::Notifications.should_receive(:instrument).with("server:stop", {:target=>server, :args=>[]}).once
        server.stop
      end
    end
  end

  describe '#instrument' do
    it 'can be called from instance' do
      ActiveSupport::Notifications.should_receive(:instrument).with("server:render", {:target=>server, :args=>[]}).once
      server.instrument(:render) { sleep 0.01 }
    end
  end
end
