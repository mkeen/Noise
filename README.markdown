Noise
=====

![Noise](http://mkeen.github.com/img/noise.png "Noise: Performant STOMP by Mike Keen")

Noise takes advantage of Rubinius' actor paradigm to enable breakneck STOMP performance in your Ruby application. It's a constant work in progress and is definitely not production ready yet. The codebase is simple, and easy to read, and I hope to keep it that way.  
  
Follow [@mikekeen](http://www.twitter.com/mikekeen) on Twitter. It's the best and fastest way to get in touch with me.  
  
How to Use
----------
You'll need Rubinius in order to use Noise. In my opinion, Rubinius is the best implementation of Ruby and I'm using it for 100% of my production code right now.  
  
**Creating a new connection:**  
  
    connection = Noise::Connection.new(:host => "localhost", :port => 61613, :username => "guest", :passcode => "guest")
*or (for the defaults)*  

    connection = Noise::Connection.new