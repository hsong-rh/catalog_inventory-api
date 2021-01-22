require 'app-common-ruby'
require 'singleton'

class ClowderConfig
  include Singleton

  def self.instance
    @instance ||= {}.tap do |options|
      if ENV["CLOWDER_ENABLED"]
        config = LoadedConfig
        options["webPorts"] = config.webPort
        options["metricsPort"] = config.metricsPort
        options["metricsPath"] = config.metricsPath
        options["kafakBrokers"] = [].tap do |brokers|
          config.kafka.brokers.each do |broker|
            brokers << "#{broker.hostname}:#{broker.port}"
          end
        end
        options["kafkaTopics"] = [].tap do |topics|
          config.kafka.topics.each do |topic|
            topics << {topic.name.to_s => topic.requestedName.to_s}
          end
        end
        options["logGroup"] = config.logging.cloudwatch.logGroup
        options["awsRegion"] = config.logging.cloudwatch.region
        options["awsAccessKeyId"] = config.logging.cloudwatch.accessKeyId
        options["awsSecretAccessKey"] = config.logging.cloudwatch.secretAccessKey
        options["databaseHostname"] = config.database.hostname
        options["databasePort"] = config.database.port
        options["databaseName"] = config.database.name
        options["databaseUsername"] = config.database.username
        options["databasePassword"] = config.database.password
      else
        options["webPorts"] = 3000
        options["metricsPort"] = 8080
        options["kafakBrokers"] = ["#{ENV['QUEUE_HOST']}:#{ENV['QUEUE_PORT']}"]
        options["logGroup"] = "platform-dev"
        options["awsRegion"] = "us-east-1"
        options["awsAccessKeyId"] = ENV['CW_AWS_ACCESS_KEY_ID']
        options["awsSecretAccessKey"] = ENV['CW_AWS_SECRET_ACCESS_KEY']
        options["databaseHostname"] = ENV['DATABASE_HOST']
        options["databaseName"] = ENV['DATABASE_NAME']
        options["databasePort"] = ENV['DATABASE_PORT']
        options["databaseUsername"] = ENV['DATABASE_USER']
        options["databasePassword"] = ENV['DATABASE_PASSWORD']
      end

      options["APP_NAME"] = "catalog-inventory"
      options["PATH_PREFIX"] = "api"

      options["SOURCES_URL"] = ENV["SOURCES_URL"]
      # TODO: update with valid url later
      options["MQTT_CLIENT_URL"] = ENV["MQTT_CLIENT_URL"] || "mqtt://localhost:1883"
      options["UPLOAD_URL"] = ENV["UPLOAD_URL"] || "https://ci.cloud.redhat.com/api/ingress/v1/upload"
      options["QUEUE_HOST"] = ENV["QUEUE_HOST"] || "localhost"
      options["QUEUE_PORT"] = ENV["QUEUE_PORT"] || "9092"
      options["CATALOG_INVENTORY_URL"] = "http://localhost:5000"
      options["CATALOG_INVENTORY_INTERNAL_URL"] = "http://localhost:5000"
    end
  end
end

# ManageIQ Message Client depends on these variables
ENV["QUEUE_HOST"] = ClowderConfig.instance["QUEUE_HOST"]
ENV["QUEUE_PORT"] = ClowderConfig.instance["QUEUE_PORT"]

# ManageIQ Logger depends on these variables
ENV['CW_AWS_ACCESS_KEY_ID'] = ClowderConfig.instance["awsAccessKeyId"]
ENV['CW_AWS_SECRET_ACCESS_KEY'] = ClowderConfig.instance["awsSecretAccessKey"]
