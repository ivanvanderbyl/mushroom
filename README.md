# Mushroom

Mushroom is a super simple wrapper around ActiveSupport Instrumentation introduced in Rails 3.

Mushroom allows any component of your application to trigger events which later get subscribed to by any
other component in your application.

The returned event can be used to handle follow up behaviour, profile running code, and event dispatch requests to
other services.

## Installation

Add this line to your application's Gemfile:

    gem 'mushroom'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mushroom

## Usage

**Simple example: Dispatch an event and receive it somewhere else**

```ruby

# app/models/server.rb
class Server
  include Mushroom

  def run
    notify :start #=> Dispatches a 'server:start' event with the current server instance as the event target.
  end
end

# lib/my_app/event_handler.rb
class EventHandler < Mushroom::Subscriber
  events :start, :on => Server

  def notify
    # Handle event here
    puts name     #=> "server:start"
    puts target   #=> <Server id:1 ...>
    puts duration #=> 0.001
  end
end

Server.new.run
```

**Slightly more advanced example: Instrument a method running, and display its duration:**

```ruby
class Server
  include Mushroom

  def start
    sleep 1
  end
  instrument :start
end

# lib/my_app/event_handler.rb
class EventHandler < Mushroom::Subscriber
  events :start, :on => Server

  def notify
    # Handle event here
    puts name     #=> "server:start"
    puts target   #=> <Server id:1 ...>
    puts duration #=> 1000.0
  end
end

Server.new.start
```

**Subscribing to multiple events:**

```ruby
# lib/my_app/event_handler.rb
class EventHandler < Mushroom::Subscriber
  events :start, :stop, :destroy, :on => Server
end
```

**Subscribing events to multiple targets**

```ruby
# lib/my_app/event_handler.rb
class EventHandler < Mushroom::Subscriber
  events :create, :destroy, :on => [Server, User, Account]
end
```

**Passing extra parameters to the subscriber**

```ruby
class Server
  include Mushroom

  def start
    notify :start, Time.now
  end
end

# lib/my_app/event_handler.rb
class EventHandler < Mushroom::Subscriber
  events :start, :on => Server

  def notify(started_at)
    puts started_at #=> 2012-04-26 16:56:54 +1000
  end
end

Server.new.start
```

Remember to declare all the arguments you expect to be received in `#notify` or you won't receive them all. You can also get the same
arguments from the `#payload` method.

## Subscriber API

The following methods are available on your Subscriber subclass:

```ruby
# payload
# name
# time
# transaction_id
# duration
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Author

- Ivan Vanderbyl
