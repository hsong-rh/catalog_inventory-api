# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  source_listener = Events::SourceListener.new(:host => ClowderConfig.queue_host, :port => ClowderConfig.queue_port)
  source_listener.run
end
