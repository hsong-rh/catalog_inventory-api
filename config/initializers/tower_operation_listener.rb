# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  tower_operation_listener = Events::TowerOperationListener.new(:host => ClowderConfig.queue_host, :port => ClowderConfig.queue_port)
  tower_operation_listener.run
end
