module Api
  module V1x0
    class SourcesController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin

      def refresh
        SourceRefreshService.new(params.require(:source_id)).process

        head :no_content
      end
    end
  end
end
