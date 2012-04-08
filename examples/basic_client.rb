require "../lib/noise.rb"

Noise::Connection.new :host => "localhost", :port => 61613, :user => "guest", :pass => "guest" do
	subscribe "/topic/mike"

	on_message do |frame|
		puts frame.to_hash[:body]
		send rand(10000).to_s, "/topic/mike"
	end

	send "this is a test of the emergency broadcasting", "/topic/mike"
end

sleep 5000