# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  ingress_listener = Events::IngressListener.new(:host => ClowderConfig.queue_host, :port => ClowderConfig.queue_port)
  ingress_listener.run
end
