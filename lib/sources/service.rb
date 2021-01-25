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
      headers = if Insights::API::Common::Request.current
                  Insights::API::Common::Request.current_forwardable
                else
                  {"x-rh-identity" => Headers::Service.x_rh_identity_dummy_admin}
                end

      sources_api.api_client.default_headers.merge!(headers)
    end
  end
end
