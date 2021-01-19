module Internal
  module V1x0
    class SourcesController < ::ApplicationController
      skip_before_action(:validate_request) # Doesn't validate against openapi.json

      include Api::V1x0::Mixins::UpdateMixin
    end
  end
end
