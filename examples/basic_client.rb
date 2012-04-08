require "../lib/noise.rb"

Noise::Connection.new :host => "localhost", :port => 61613, :user => "guest", :pass => "guest" do
	subscribe "/topic/mike"
	send "hello", "/topic/mike"
end

sleep 100