Noise
=====

![Noise](http://mkeen.github.com/img/noise.png "Noise: Performant STOMP by Mike Keen")

Noise takes advantage of Rubinius' actor paradigm to enable breakneck STOMP performance in your Ruby application. The codebase is simple, and easy to read, and I hope to keep it that way.  
  
Twitter ([@mikekeen](http://www.twitter.com/mikekeen)) is the best and fastest way to get in touch with me.  
  
What do I need to use Noise?
----------
Noise makes heavy use of Rubinius' actors. Use rvm to install Rubinius if you don't already have it. `rvm install rbx`  
Noise has been tested with RabbitMQ's STOMP plugin.

What can I do with Noise?
----------
You can create scalable realtime Web services that send and receive STOMP commands. You can build protocols on top of it in order to power your stuff. I'll add more straightforward ways to create protocols and services soon. For now, you can do it manually.

What doesn't Noise have right now that it will soon?
----------
Test coverage, error reporting, a connection per subscription by default.

**Installation:**

```bash    
gem build noise.gemspec
gem install Noise-0.0.1.gem
```

**Creating a new connection and doing some stuff with it:**  

```ruby 
require "rubygems"
require "noise"
Noise::Connection.new :host => "localhost", :port => 61613, :user => "guest", :pass => "guest" do
  # At this point, you are connected to the server and the login you specified has been verified.
  subscribe "/topic/noise"

  on_message do |frame|
    puts "received a message. including ones from the above subscription"
    puts frame.to_hash[:body]
    send rand(10000).to_s, "/topic/noise"
  end

  on "message", false do |frame|
    puts "received a message. this event callback will only fire once"
  end

  send "this is a test of the emergency broadcasting system", "/topic/noise"
end

# You will need to keep the process alive somehow in order to listen for incoming messages.
# You can do better than this:

sleep 500
```

Is this in active development?
----------
I am developing this in my spare time but I will respond promptly to bug reports and pull requests.