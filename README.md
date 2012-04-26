# Mushroom

Mushroom is a super simple wrapper around ActiveSupport Instrumentation introduced in Rails 3.

Muchroom allows any component of your application to trigger events which later get subscribed to by any
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

```ruby

# app/models/server.rb
class Server
  include Mushroom

  def run
    notify :start #=> Dispatches a 'server:start' event with the current server instance as the event target.
  end

  # You can instrument methods inline.
  # This will trigger the server:stop event when you call #stop
  # and notify all subscribers to the stop event.
  #
  # The server:stop event #duration will be 1 second.
  #
  def stop
    sleep 1
  end
  instrument :stop
end

# lib/my\_app/event\_handler.rb
class EventHandler < Muchroom::Subscriber
  events :start, :stop, :on => Server
  events :cleanup, :on => ServerCache

  def notify
    # Handle event here
    puts name     #=> "server:start"
    puts target   #=> <Server id:1 ...>
    puts duration #=> 0.001
  end
end

Server.new.run
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Author

- Ivan Vanderbyl
