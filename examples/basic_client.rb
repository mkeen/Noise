require "../lib/noise.rb"

Noise::Connection.new(:host => "68.71.141.216", :port => 443, :user => "guest", :pass => "guest") do
  subscribe("/topic/click.announce")
end

sleep 500