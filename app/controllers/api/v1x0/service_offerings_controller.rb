module Api
  module V1x0
    class ServiceOfferingsController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin
      include Mixins::SourcesApiMixin

      def order
        send_message_and_generate_task_for(:order)
      end

      # POST
      def applied_inventories
        send_message_and_generate_task_for(:applied_inventories)
      end

      private

      def send_message_and_generate_task_for(operation_type)
        operation_params = send("params_for_#{operation_type}".to_sym)

        logger.info("ServiceOffering##{operation_type}: Entering method send_message_and_generate_task_for with params #{operation_params.inspect}")

        service_offering = model.find(operation_params[:service_offering_id].to_i)

        task_opts = {:name => "ServiceOffering##{operation_type}", :source_id => service_offering.source_id, :forwardable_headers => Insights::API::Common::Request.current_forwardable, :tenant => service_offering.tenant, :state => "pending", :status => "ok"}

        task = operation_type.to_s == "order" ? LaunchJobTaskService.new(params.to_unsafe_h).process.task : Task.create!(task_opts)

        task.dispatch

        logger.info("ServiceOffering##{operation_type}: ServiceOffering(id: #{service_offering.id}, source_ref: #{service_offering.source_ref}): Task(id: #{task.id}) created.")

        payload = send("payload_for_#{operation_type}".to_sym, task, service_offering)

        logger.info("ServiceOffering##{operation_type}: Task(id: #{task.id}), ServiceOffering(id: #{service_offering.id}, source_ref: #{service_offering.source_ref}): Publishing event(ServiceOffering.#{operation_type}) to kafka")

        logger.info("ServiceOffering##{operation_type}: ServiceOffering(id: #{service_offering.id}, source_ref: #{service_offering.source_ref}), Task(id: #{task.id}): event(ServiceOffering.#{operation_type}) published to kafka.")

        render :json => {:task_id => task.id}
      rescue ActiveRecord::RecordNotFound => err
        logger.error("ServiceOffering##{operation_type}: #{err.message}")
        head :bad_request
      rescue StandardError => err
        logger.error("ServiceOffering##{operation_type}: ServiceOffering(id: #{operation_params[:service_offering_id].to_i }, source_ref: #{service_offering&.source_ref}), #{task ? "Task(id: #{task.id}):" : ""}#{err.message} (#{err.class})")
        error_document = Insights::API::Common::ErrorDocument.new.add(err.message)
        render :json => error_document.to_h, :status => error_document.status
      end

      def params_for_order
        @params_for_order ||= params.permit(
          :service_offering_id,
          :service_plan_id,
          :service_parameters          => {},
          :provider_control_parameters => {}
        ).to_h
      end

      def params_for_applied_inventories
        @params_for_applied_inventories ||= params.permit(
          :service_offering_id,
          :service_parameters => {}
        ).to_h
      end

      def payload_for_order(task, service_offering)
        payload = {
          :request_context => Insights::API::Common::Request.current_forwardable,
          :params          => {
            :order_params        => params_for_order,
            :service_offering_id => service_offering.id.to_s,
            :task_id             => task.id.to_s,
          }
        }
        payload[:params][:service_plan_id] = params_for_order[:service_plan_id].to_s if params_for_order[:service_plan_id].present?
        payload
      end

      def payload_for_applied_inventories(task, service_offering)
        {
          :request_context => Insights::API::Common::Request.current_forwardable,
          :params          => {
            :inventory_params    => params_for_applied_inventories,
            :service_offering_id => service_offering.id.to_s,
            :task_id             => task.id.to_s
          }
        }
      end
    end
  end
end
