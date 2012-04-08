require "actor"
require "socket"
require "fcntl"
require "stringio"

class Noise::Connection
  @@supervisor = nil
  @@new = Struct.new(:instance)
  @@byte = Struct.new(:packet)
  @@full = Struct.new(:empty)
  @@out = Struct.new(:frame)
  
  class << self
    def supervisor
      Actor.spawn do
        supervisor = Actor.current
        loop do
          Actor.receive do |request|
            request.when @@new do |req|
              child = Actor.spawn_link(&req.instance.connection_receiver)
              Actor.register(req.instance.object_id.to_s.to_sym, child)
            end
            
          end
          
        end
        
      end
      
    end
    
  end

  # Create a new connection to the server
  def initialize args, &block
    on_connect &block unless block.nil?
    @@supervisor ||= Noise::Connection.supervisor
    @hostname = args[:hostname] || args[:host] || "localhost"
    @port = args[:port] || 61613
    @login = args[:login] || args[:username] || args[:user] || "guest"
    @passcode = args[:passcode] || args[:password] || args[:pass] || "guest"
    @@supervisor << @@new[self]
  end
  
  # Run a block when we connect. If forever is true, this block will run each time
  # the program receives a CONNECTED command
  def on_connect forever = false, &block
    on "connected", forever, &block
  end

  # Run a block when the program receives a message. If destination does not equal :all
  # then 
  def on_message destination = :all, forever = true, &block
    if destination == :all
      on "message", forever, &block
    else
      on "message", forever do |frame|
        block.call unless frame.headers[:destination] != destination
      end

    end

  end

  def login
    write Noise::Frame.new :command => "connect", :headers => {:login => @login, :passcode => @passcode}
  end

  def logout
    write Noise::Frame.new :command => "disconnect"
  end

  def subscribe destination
    actor << @@out[Noise::Frame.new(:command => "subscribe", :headers => {:destination => destination})]
  end

  def send msg, destination
    #actor << @@out[Noise::Frame.new(:command => "send", :headers => {:destination => destination}, :body => msg)]
    actor << @@out[Noise::Frame.new(:command => "send", :headers => {:destination => destination}, :body => msg)]
  end


  def live duration
    waiter = nil
    if duration.class == "Symbol"
      case duration
      when :forever
        waiter = Proc.new do
          loop do
            sleep 3600
          end

        end

      end

    else
      waiter = Proc new do
        sleep duration
      end

    end

    thread = Thread.new waiter
    thread.join
  end

  # Returns a process that is used as a receiver for the socket
  def connection_receiver
    Proc.new do
      start
      buffer = StringIO.new
      loop do
        Actor.receive do |request|
          request.when @@full do
            received_frame Noise::Frame.new buffer.string
            buffer = StringIO.new
          end
          
          request.when @@out do |request|
            write request[:frame]
          end
          
          request.when @@byte do |byte|
            if byte[:packet] === Noise::Frame.zero
              Actor.current << @@full[0]
            else
              buffer << byte[:packet]
            end
            
          end
          
        end
        
      end
      
    end
    
  end

  # Wait for the actor to be created before running the specified block
  def ensure_ready &block
    Thread.new do
      loop do
        if !actor.nil?
          block.call
          break
          
        end
      
      end
      
    end
    
  end

  # Establish a loop for reading data off of the socket
  # note: reading 1 byte at a time from the socket. common sense tells
  # me that this might not be performant, but I have a feeling there is
  # someone out there that knows an optimal read amount.
  #
  # Future: This needs to manage multiple open sockets at once for speed
  def wait
    Thread.new do
      if IO.select([@socket])
        while byte = @socket.read(1)
          actor << @@byte[byte]
        end

      end

    end
    
  end

  # Honor subscriptions by running a block specified at some earlier time
  # and also by deleting the subscription once it runs if forever was set
  # to false at the time the subscription was created
  def received_frame frame
    @subscriptions[frame.to_hash[:command]].each do |proc|
      if proc.call == false
        @subscriptions[frame.to_hash[:command]].delete proc
      end

    end

  end

  # Create a subscription to incoming stomp commands. Eg: "connect",
  # "message", etc. If forever is true, this block will fire each
  # time the command is received. If forever is set to false, it will
  # just fire once. Which will be the next time the command is received
  def on command, forever = true, &block
    @subscriptions ||= {}
    @subscriptions[command.upcase] ||= []
    @subscriptions[command.upcase] << Proc.new do
      instance_eval &block
      # Return the param "forever", which was passed to "on", so that
      # the received_frame method will know whether to remove the sub
      # or not.
      forever
    end

  end

  # Returns the actor that corresponds to the current instance of
  # Noise::Connection
  def actor
    @actor ||= Actor.lookup(self.object_id.to_s.to_sym)
  end

  # Writes a Noise::Frame to the socket connection
  def write frame
    @socket.write frame
  end
  
  # Start a STOMP session and listen for input on the socket
  def start
    # Todo: Throw an exception or log something if the socket connection fails.
    # either being inside another thread or the actor when this is called is
    # possibly the reason nothing obvious happens here if the stomp service is
    # down or not listening on the specified port.
    @socket = TCPSocket.new @hostname, @port
    login
    wait
  end

end