# Be sure to restart your server when you modify this file.

unless defined?(::Rails::Console)
  queue_host = ENV["QUEUE_HOST"] || "localhost"
  queue_port = ENV["QUEUE_PORT"] || 9092
  
  tower_operation_listener = Events::TowerOperationListener.new(:host => queue_host, :port => queue_port)
  tower_operation_listener.run
end
  
