require 'mqtt'
require 'net/http'
require 'uri'
require 'json'

class MQTTControllerService
  API_VERSION = "v1".freeze
  DIRECTIVE = "catalog".freeze

  def initialize(options)
    @options = options.deep_symbolize_keys

    validate_options
    @task_id  = @options[:task_id]
    @task_url = @options[:task_url]
    @mqtt_client_guid = @options[:mqtt_client_guid]
    @mqtt_client_url  = @options[:mqtt_client_url]
  end

  # TODO: will replace by the mqtt controller in cluster
  def process
    Rails.logger.info("publish: #{payload}")
    send_to_cloud_controller
  end

  private

  def send_to_cloud_controller
    account = "111000"
    x_rh_identity="eyJlbnRpdGxlbWVudHMiOnsiaW5zaWdodHMiOnsiaXNfZW50aXRsZWQiOnRydWUsImlzX3RyaWFsIjpmYWxzZX0sImNvc3RfbWFuYWdlbWVudCI6eyJpc19lbnRpdGxlZCI6dHJ1ZSwiaXNfdHJpYWwiOmZhbHNlfSwibWlncmF0aW9ucyI6eyJpc19lbnRpdGxlZCI6dHJ1ZSwiaXNfdHJpYWwiOmZhbHNlfSwiYW5zaWJsZSI6eyJpc19lbnRpdGxlZCI6dHJ1ZSwiaXNfdHJpYWwiOmZhbHNlfSwidXNlcl9wcmVmZXJlbmNlcyI6eyJpc19lbnRpdGxlZCI6dHJ1ZSwiaXNfdHJpYWwiOmZhbHNlfSwib3BlbnNoaWZ0Ijp7ImlzX2VudGl0bGVkIjp0cnVlLCJpc190cmlhbCI6ZmFsc2V9LCJzbWFydF9tYW5hZ2VtZW50Ijp7ImlzX2VudGl0bGVkIjp0cnVlLCJpc190cmlhbCI6ZmFsc2V9LCJzdWJzY3JpcHRpb25zIjp7ImlzX2VudGl0bGVkIjp0cnVlLCJpc190cmlhbCI6ZmFsc2V9LCJzZXR0aW5ncyI6eyJpc19lbnRpdGxlZCI6dHJ1ZSwiaXNfdHJpYWwiOmZhbHNlfX0sImlkZW50aXR5Ijp7ImludGVybmFsIjp7ImF1dGhfdGltZSI6Nzk5LCJvcmdfaWQiOiIxMTc4OTc3MiJ9LCJhY2NvdW50X251bWJlciI6IjYwODk3MTkiLCJhdXRoX3R5cGUiOiJiYXNpYy1hdXRoIiwidXNlciI6eyJpc19hY3RpdmUiOnRydWUsImxvY2FsZSI6ImVuX1VTIiwiaXNfb3JnX2FkbWluIjp0cnVlLCJ1c2VybmFtZSI6Imluc2lnaHRzLXFhIiwiZW1haWwiOiJkYWpvaG5zb0ByZWRoYXQuY29tIiwiZmlyc3RfbmFtZSI6Ikluc2lnaHRzIiwidXNlcl9pZCI6IjUxODM0Nzc2IiwibGFzdF9uYW1lIjoiUUEiLCJpc19pbnRlcm5hbCI6dHJ1ZX0sInR5cGUiOiJVc2VyIn19"
    cc_url = File.join(@mqtt_client_url, API_VERSION, "message")
    body = {'account':   account,
            'recipient': @mqtt_client_guid,
            'directive': DIRECTIVE,
            'payload':   payload}
    uri = URI.parse(cc_url)

    header = {'Content-Type': 'application/json',
              'X-RH-IDENTITY': x_rh_identity}
    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json

    # Send the request
    response = http.request(request)
    Rails.logger.info("Sent message for #{@mqtt_client_guid} #{response.code} #{response.message}")
    # TODO: We should store the message ID coming back in our task table for tracking

    Rails.logger.info("Cloud Controller response #{@mqtt_client_guid} #{response.body}")
  rescue => error
    Rails.logger.error("Error sending message to cloud controller #{@mqtt_client_guid} #{error}")
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
