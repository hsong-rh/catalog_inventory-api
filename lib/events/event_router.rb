module Events
  class EventRouter
    def self.dispatch(event_type, payload, headers = nil)
      case event_type
      when "Catalog.upload"
        PersisterTaskService.new(payload).process
      when "Source.create"
        SourceCreateTaskService.new(payload).process
      when "Source.availability_check"
        task = CheckAvailabilityTaskService.new(payload).process.task
        task.dispatch
      when "Endpoint.create"
        EndpointCreateTaskService.new(payload).process
      else
        Rails.logger.warn("Event type: #{event_type} is not supported.")
      end
    end
  end
end
