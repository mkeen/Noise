require "rubinius/actor"
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
      Rubinius::Actor.spawn do
        supervisor = Actor.current
        
        loop do
          Rubinius::Actor.receive do |request|
            request.when @@new do |req|
              child = Rubinius::Actor.spawn_link(&req.instance.connection)
              Rubinius::Actor.register(req.instance.object_id.to_s.to_sym, child)
            end
            
          end
          
        end
        
      end
      
    end
    
  end
  
  def initialize args
    @@supervisor ||= Noise::Connection.supervisor
    @hostname = args[:hostname] || args[:host] || "localhost"
    @port = args[:port] || 61613
    @login = args[:login] || args[:username] || args[:user] || "guest"
    @passcode = args[:passcode] || args[:password] || args[:pass] || "guest"
    @callback = Proc.new {|data| puts data}
    @@supervisor << @@new[self]
  end
  
  def actor
    @actor ||= Rubinius::Actor.lookup(self.object_id.to_s.to_sym)
  end
  
  def write frame
    @socket.write(frame)
  end
  
  def start
    @socket = TCPSocket.new(@hostname, @port)
    login
    wait
  end
  
  def login
    # This should never be refactored to actor << @@out because this call needs to block
    write(Noise::Frame.new(:command => "connect", :headers => {:login => @login, :passcode => @passcode}))
  end
  
  def wait
    Thread.new do
      loop do
        if IO.select([@socket])
          actor << @@byte[@socket.read(1)]
        end
      
      end
      
    end
    
  end
  
  def subscribe destination
    ensure_ready do
      actor << @@out[Noise::Frame.new(:command => "subscribe", :headers => {:destination => destination})]
    end
    
  end
  
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
  
  def connection
    Proc.new do
      start
      buffer = StringIO.new
      
      loop do
        Rubinius::Actor.receive do |request|
          request.when @@full do
            @callback.call(buffer.string)
            buffer = StringIO.new
          end
          
          request.when @@out do |request|
            write(request[:frame])
          end
          
          request.when @@byte do |byte|
            if byte[:packet] === Noise::Frame.zero
              Rubinius::Actor.current << @@full[0]
            else
              buffer << byte[:packet]
            end
            
          end
          
        end
        
      end
      
    end
    
  end
  
end