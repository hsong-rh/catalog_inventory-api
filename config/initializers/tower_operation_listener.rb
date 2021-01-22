# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  queue_host = ClowderConfig.instance["QUEUE_HOST"]
  queue_port = ClowderConfig.instance["QUEUE_PORT"]

  tower_operation_listener = Events::TowerOperationListener.new(:host => queue_host, :port => queue_port)
  tower_operation_listener.run
end
