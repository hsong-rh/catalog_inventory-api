# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  queue_host = ENV["QUEUE_HOST"] || "localhost"
  queue_port = ENV["QUEUE_PORT"] || 9092
  
  ingress_listener = IngressListener.new(:host => queue_host, :port => queue_port)
  ingress_listener.run
end
  