module Sources
  class Service
    def self.sources_api
      Thread.current[:sources_api_instance] ||= raw_api
    end

    def self.call
      pass_thru_headers
      yield sources_api
    rescue SourcesApiClient::ApiError => e
      Rails.logger.error("SourcesApiClient::ApiError #{e.message}")
    end

    private_class_method def self.raw_api
      SourcesApiClient.configure do |config|
        config.host = ClowderConfig.instance['SOURCES_URL'] || 'localhost'
        config.scheme = URI.parse(ClowderConfig.instance['SOURCES_URL']).try(:scheme) || 'http'
        if Rails.env.development?
          config.username = ENV['DEV_USERNAME'] || raise("Empty ENV variable: DEV_USERNAME")
          config.password = ENV['DEV_PASSWORD'] || raise("Empty ENV variable: DEV_PASSWORD")
        end
      end
      SourcesApiClient::DefaultApi.new
    end

    private_class_method def self.pass_thru_headers
      headers = {"x-rh-identity" => Base64.strict_encode64(User::DEFAULT_USER.to_json)}
      sources_api.api_client.default_headers.merge!(headers)
    end
  end

  module User
    DEFAULT_USER ||= {
      "identity" => {
        "account_number" => "DUMMY_USER",
        "type"           => "User",
        "user"           => {
          "username"     => "dummy_user",
          "email"        => "dummy_user@redhat.com",
          "first_name"   => "dummy",
          "last_name"    => "user",
          "is_active"    => false,
          "is_org_admin" => true,
          "is_internal"  => false,
          "system"       => true,
          "locale"       => "en_US"
        },
        "internal"       => {
          "org_id"    => "1234567",
          "auth_type" => "basic-auth",
          "auth_time" => 6300
        }
      }
    }.freeze
  end
end
