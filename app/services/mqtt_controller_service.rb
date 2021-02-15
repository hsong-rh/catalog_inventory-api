require 'mqtt'
require 'net/http'
require 'uri'
require 'json'

class MQTTControllerService
  API_VERSION = "v1".freeze
  DIRECTIVE = "catalog".freeze
  VALID_STATUS_CODES = %w[200 201 202].freeze
  def initialize(options)
    @options = options.deep_symbolize_keys

    validate_options
    @task_id  = @options[:task_id]
    @task_url = @options[:task_url]
    @mqtt_client_guid = @options[:mqtt_client_guid]
    @mqtt_client_url  = @options[:mqtt_client_url]
    @task = Task.find(@task_id)
  end

  # TODO: will replace by the mqtt controller in cluster
  def process
    Rails.logger.info("publish: #{payload}")
    send_to_cloud_controller
  end

  private

  def send_to_cloud_controller
    account = @task.tenant.external_tenant
    # TODO: Remove account once Cloud Controller starts getting the account #
    account = "111000"

    cc_url = File.join(@mqtt_client_url, API_VERSION, "message")
    body = {'account':   account,
            'recipient': @mqtt_client_guid,
            'directive': DIRECTIVE,
            'payload':   payload}
    uri = URI.parse(cc_url)

    header = {'Content-Type': 'application/json'}.merge(Insights::API::Common::Request.current_forwardable)
    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json

    # Send the request
    response = http.request(request)
    Rails.logger.info("Sent message for #{@mqtt_client_guid} #{response.code} #{response.message}")

    VALID_STATUS_CODES.include?(response.code) ? @task.update!(:controller_message_id => JSON.parse(response.body)['id']) : task_failed(response.body)
  rescue => error
    task_failed(error)
  end

  def task_failed(error)
    Rails.logger.error("Error sending message to cloud controller node id: #{@mqtt_client_guid} #{error}")
    @task.update_attributes(:state => "completed", :status => "error", :output => {'errors' => ["#{error}"]} )
  end

  def validate_options
    unless @options[:task_id].present? && @options[:task_url].present? && @options[:mqtt_client_url].present? && @options[:mqtt_client_guid].present?
      raise("Options must have task_id, task_url, mqtt_client_url and mqtt_client_guid keys")
    end
  end

  def publish
    u = URI.parse(@mqtt_client_url)
    client = MQTT::Client.new
    if u.scheme == "mqtts"
      client.ssl = true
    end
    client.host = u.host
    client.port = u.port
    client.connect
    ### Publlish a message on the topic "/paho/ruby/test" with "retain == false" and "qos == 1"
    client.publish("out/#{@mqtt_client_guid}", "#{payload}", false, 1)

    sleep 1
    client.disconnect
  rescue => error
    Rails.logger.error("Error publishing MQTT Message #{@mqtt_client_guid} #{error}")
  end

  def payload
    {"URL" => "#{@task_url}/#{@task_id}"}
  end
end
