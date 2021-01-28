module Api
  module V1x0
    class ServiceOfferingsController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin
      include Mixins::SourcesApiMixin

      def order
        service_offering_order
      end

      def applied_inventories_tags
        service = CollectInventoriesService.new(params[:service_offering_id]).process

        render :json => service.inventory_tags
      end

      private

      def service_offering_order
        task = LaunchJobTaskService.new(params.to_unsafe_h).process.task
        task.dispatch

        render :json => {:task_id => task.id}
      end
    end
  end
end
