# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  queue_host = ClowderConfig.instance["QUEUE_HOST"]
  queue_port = ClowderConfig.instance["QUEUE_PORT"]

  ingress_listener = Events::IngressListener.new(:host => queue_host, :port => queue_port)
  ingress_listener.run
end
