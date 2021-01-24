class SourceDestroyTaskService
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  def process
    return if ClowderConfig.instance["SOURCE_TYPE_ID"] != @options[:source_type_id]

    validate_options
    Source.destroy(@options[:id])
  end

  private

  def validate_options
    raise("Options must have id key") unless @options.key?(:id)
  end
end
