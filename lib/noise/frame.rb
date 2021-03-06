class Noise::Frame
  @@zero = "\0"
  @@newline = "\n"
  
  class << self
    def zero
      @@zero
    end
    
  end
  
  # Can either pass in a hash to create a frame, or an existing frame in text format
  # in order to provide it with some structure.
  def initialize args
    if args.class == String
      from_string args
    else
      from_hash args
    end
    
  end
  
  # Modifies the attributes of the current class instance to match the data parsed from the STOMP string
  # This function is fucked, and shouldn't be used much anyway. Frames should be parsed as a stream, not
  # as one chunk as this encourages
  def from_string str
    str = str.chomp
    @headers = {}
    @body = ""
    parse_headers = str.split @@newline
    @command = parse_headers.shift
    parse_headers.delete_if do |item|
      !item.include?(":")
    end

    parse_headers.each do |header|
      split = header.split ":"
      (@headers[split[0].chomp] = split[1].chomp) unless split.length < 2
    end

    if @headers.include? "content-length"
      @body = str[-(@headers["content-length"].to_i)..-1].chomp unless @headers["content-length"].to_i < 1
    else
      split = str.split(@@newline * 2)
      @body = split[split.length - 1]
    end

    puts @body
  end

  # Modifies the attributes of the current class instance to match the data in the hash
  def from_hash hsh
    @command = hsh[:command]
    @headers = hsh[:headers]
    @body = hsh[:body] || ""
  end

  def command
    @command.upcase + @@newline
  end

  def to_hash
    {:command => @command.upcase, :headers => @headers, :body => @body}
  end
  
  def headers
    headers = ""
    @headers.keys.each do |key|
      headers << "%s:%s%s" % [key, @headers[key], @@newline]
    end
    
    headers[0..-2]
  end
  
  def body
    @body + (@@newline * 2)
  end
  
  def to_s
    command + headers + (@@newline * 2) + body + @@zero
  end
  
end