class Noise::Frame
  @@zero = "\0"
  
  class << self
    def zero
      @@zero
    end
    
  end
  
  def initialize args
    @command = args[:command]
    @headers = args[:headers]
    @body = args[:body] || ""
  end
  
  def command
    @command.upcase + "\n"
  end
  
  def headers
    headers = ""
    @headers.keys.each do |key|
      headers << "%s:%s\n" % [key, @headers[key]]
    end
    
    headers
  end
  
  def body
    @body + "\n"
  end
  
  def to_s
    command + headers + body + @@zero
  end
  
end