module Events
  class KafkaListener
    attr_accessor :messaging_client_options, :service_name, :group_ref

    def initialize(messaging_client_options, service_name, group_ref)
      self.messaging_client_options = default_messaging_options.merge(messaging_client_options)
      self.service_name = service_name
      self.group_ref = group_ref
    end

    def run
      Thread.new { subscribe }
    end

    def subscribe
      ManageIQ::Messaging::Client.open(messaging_client_options) do |client|
        client.subscribe_topic(
          :service     => service_name,
          :persist_ref => group_ref,
          :max_bytes   => 500_000
        ) do |event|
          raw_process(event)
        end
      end
    rescue => e
      Rails.logger.error(["Something is wrong with Kafka client: ", e.message, *e.backtrace].join($RS))
      retry
    end

    private

    def raw_process(event)
      Rails.logger.info("Kafka message #{event.message} received with payload: #{event.payload}")

      insights_headers = event.headers.slice('x-rh-identity', 'x-rh-insights-request-id')

      # Kafka message from Ingress has no headers. We need to prepare the headers from its payload.
      if insights_headers.empty?
        if event.payload.class == Hash && event.payload.has_key?("params") 
          # check availability from source doesn't have headers
          insights_headers['x-rh-insights-request-id'] = "unknown"
          insights_headers['x-rh-identity'] = identity_from_external_tenant(event.payload["params"]["external_tenant"])
        else 
          # ingress doesn't have any header
          header_hash = json.parse(event.payload)
          insights_headers['x-rh-insights-request-id'] = header_hash["request_id"]
          insights_headers['x-rh-identity'] = header_hash["b64_identity"]
        end
      end

      unless insights_headers['x-rh-identity'] && insights_headers['x-rh-insights-request-id']
        rails.logger.error("message skipped because of missing required headers")
        return
      end

      Insights::API::Common::Request.with_request(:headers => insights_headers, :original_url => nil) do |req|
        tenant = Tenant.first_or_create(:external_tenant => req.tenant)
        if tenant
          ActsAsTenant.with_tenant(tenant) do
            ActiveRecord::Base.connection_pool.with_connection do
              process_event(event)
            end
          end
        else
          Rails.logger.error("Message skipped because it does not belong to a valid tenant")
        end
      end
    rescue => e
      Rails.logger.error(["Error processing event: ", e.message, *e.backtrace].join($RS))
    ensure
      event.ack
    end

    def default_messaging_options
      {:protocol => :Kafka, :encoding => 'json'}
    end

    def identity_from_external_tenant(account_number)
      hash = {
        "entitlements" => {
          "ansible"          => {
            "is_entitled" => true
          },
          "hybrid_cloud"     => {
            "is_entitled" => true
          },
          "insights"         => {
            "is_entitled" => true
          },
          "migrations"       => {
            "is_entitled" => true
          },
          "openshift"        => {
            "is_entitled" => true
          },
          "smart_management" => {
            "is_entitled" => true
          }
        },
        "identity" => {
          "account_number" => account_number,
          "type"           => "User",
          "auth_type"      => "basic-auth",
          "user"           =>  {
            "username"     => "jdoe",
            "email"        => "jdoe@acme.com",
            "first_name"   => "John",
            "last_name"    => "Doe",
            "is_active"    => true,
            "is_org_admin" => false,
            "is_internal"  => false,
            "locale"       => "en_US"
          },
          "internal"       => {
            "org_id"    => "3340851",
            "auth_time" => 6300
          }
        }
      }
      Base64.strict_encode64(hash.to_json)
    end
  end
end
