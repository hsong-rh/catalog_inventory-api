class ApplicationTaskService
  def initialize(options)
    @options = options.deep_symbolize_keys
    validate_options
  end

  def process
    return if ClowderConfig.instance["APPLICATION_TYPE_ID"].blank? || ClowderConfig.instance["APPLICATION_TYPE_ID"] != @options[:application_type_id].to_s

    Source.update(@options[:source_id], :enabled => @options[:enabled])
  end

  private

  def validate_options
    raise("Options must have source_id and application_type_id keys") unless @options[:source_id].present? && @options[:application_type_id].present?
  end
end
