# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  queue_host = ClowderConfig.instance["QUEUE_HOST"]
  queue_port = ClowderConfig.instance["QUEUE_PORT"]

  source_listener = Events::SourceListener.new(:host => queue_host, :port => queue_port)
  source_listener.run
end
