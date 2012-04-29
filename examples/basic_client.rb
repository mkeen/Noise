require "../lib/noise.rb"

Noise::Connection.new :host => "37.153.96.41", :port => 61613, :user => "admin", :pass => "shadowwood" do
  # At this point, you are connected to the server and the login you specified has been verified.
  subscribe "/topic/noise"

  on_message do |frame|
    send rand(10000).to_s, "/topic/noise"
  end

  on "message", false do |frame|
    puts "received a message. this event callback will only fire once"
  end

  send "this is a test of the emergency broadcasting system", "/topic/noise"
end

# You will need to keep the process alive somehow in order to listen for incoming messages.
# You can do better than this:

sleep 1000000000