module Api
  module V1x0
    class SourcesController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin

      def refresh
        SourceRefreshService.new(params.require(:source_id)).process

        head :no_content
      rescue CatalogInventory::Exceptions::RecordLockedException, CatalogInventory::Exceptions::RefreshAlreadyRunningException => e
        render :json => {:message => e.message}, :status => :too_many_requests
      end
    end
  end
end
