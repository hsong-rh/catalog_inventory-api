module Api
  module V1x0
    class RootController < ApplicationController
      def openapi
        render :json => ::Insights::API::Common::OpenApi::Docs.instance["1.0"].to_json
      end
    end
  end
end
