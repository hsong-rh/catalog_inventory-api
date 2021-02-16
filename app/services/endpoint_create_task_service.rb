class EndpointCreateTaskService
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  def process
    validate_options
    Source.update(@options[:source_id], :mqtt_client_id => @options[:receptor_node])

    Rails.logger.info("Starting availability check for source #{@options[:source_id]}")
    task = CheckAvailabilityTaskService.new(@options).process.task
    task.dispatch
  end

  def validate_options
    raise("Options must have source_id and receptor_node keys") unless @options[:source_id].present? && @options[:receptor_node].present?
  end
end
