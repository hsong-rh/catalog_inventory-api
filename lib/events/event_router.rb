module Events
  class EventRouter
    def self.dispatch(event_type, payload, headers = nil)
      case event_type
      when "Catalog.upload"
        # TODO add service later
      when "Source.create"
        SourceCreateTaskService.new(payload).process
      when "Source.availability_check"
        # TODO add service later
      when "Endpoint.create"
        # TODO add service later
      else
        Rails.logger.warn("Event type: #{event_type} is not supported.")
      end
    end
  end
end
