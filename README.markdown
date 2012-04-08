Noise
=====

![Noise](http://mkeen.github.com/img/noise.png "Noise: Performant STOMP by Mike Keen")

Noise takes advantage of Rubinius' actor paradigm to enable breakneck STOMP performance in your Ruby application. It's a constant work in progress and is definitely not production ready yet. The codebase is simple, and easy to read, and I hope to keep it that way.  
  
Twitter ([@mikekeen](http://www.twitter.com/mikekeen)) is the best and fastest way to get in touch with me.  
  
What do I need to use Noise?
----------
Noise makes heavy use of Rubinius' actors. Use rvm to install Rubinius if you don't already have it. `rvm install rbx`  
Noise has been tested with RabbitMQ's STOMP plugin.

What can I do with Noise?
----------
You can create scalable realtime Web services that send and receive STOMP commands. You can build protocols on top of it in order to power your stuff. I'll add more straightforward ways to create protocols and services soon. For now, you can do it manually.

**Installation:**
    
    gem build noise.gemspec
    gem install Noise-0.0.1.gem

**Creating a new connection:**  
    
    require "rubygems"
    require "noise"
    Noise::Connection.new :host => "localhost", :port => 61613, :user => "guest", :pass => "guest" do
      puts "Connection established"
      subscribe "/topic/mikekeen" do |msg|
        puts "received " + msg + " from /topic/mikekeen"
      end

      on_message do |msg|
         puts "received a message. including ones from the above subscription"
         puts msg
      end

      on "message", false do |msg|
        puts "received a message. this event callback will only fire once"
      end

    end