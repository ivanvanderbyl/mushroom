require "spec_helper"

describe Mushroom::Subscriber do

  class Server
  end

  class Dummy
  end

  class EventHandler < Mushroom::Subscriber
    def notify
    end
  end

  class ServerEventHandler < Mushroom::Subscriber
    def notify
    end
  end

  after do
    EventHandler.send(:_events=, {})
  end

  describe '.events' do
    it 'allows adding event for a class' do
      lambda { EventHandler.events :destroy, :on => Server }.should_not raise_error
      EventHandler.events.should == ['server:destroy']
    end

    it 'stores events which weve added' do
      EventHandler.events :start, :stop, :on => Server
      EventHandler.events.should == ['server:start', 'server:stop']
    end

    it 'allows adding events for the same target multiple times' do
      EventHandler.events :start, :on => Server
      EventHandler.events :stop, :on => Server
      EventHandler.events.should == ['server:start', 'server:stop']
    end

    it 'allows subscribing the same events to multiple targets' do
      EventHandler.events :start, :on => [Server, Dummy]
      EventHandler.events.should == ['server:start', 'dummy:start']
    end

    it 'does not inherit events across subscribers' do
      EventHandler.send(:_events=, {})
      EventHandler.events :stop, :on => Dummy
      ServerEventHandler.events.should == []
      ServerEventHandler.events :start, :on => Server
      EventHandler.events.should == ['dummy:stop']
    end

    it 'should be thread safe' do
      t1 = Thread.new { EventHandler.events :start, :on => Server }
      t1.join
      EventHandler.events.should == []
    end
  end

  describe '.notify' do
    it 'gets called when an event is triggered' do
      class CustomHandler < Mushroom::Subscriber
        events :start, :on => Server
      end
      CustomHandler.should_receive(:notify).once
      Server.new.notify(:start)
    end

    it 'passes arguments to subscriber' do
      class CustomHandler < Mushroom::Subscriber
        events :start, :on => Server

        def notify(payload)
          payload.should == {:payload => {:id => 123}}
        end
      end

      Server.new.notify(:start, {:payload => {:id => 123}})
    end

    it 'passes multiple arguments to subscriber' do
      Thread.current[:now] = Time.now

      class CustomHandler < Mushroom::Subscriber
        events :start, :on => Server

        def notify(payload, time)
          payload.should == {:payload => {:id => 123}}
          time.should_not == nil
          time.should == Thread.current[:now]
        end
      end

      Server.new.notify(:start, {:payload => {:id => 123}}, Thread.current[:now])
    end

  end
end

