class SourceDestroyTaskService
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  def process
    return if ENV["SOURCE_TYPE_ID"].blank? || ENV["SOURCE_TYPE_ID"] != @options[:source_type_id]

    validate_options
    Source.destroy(@options[:source_id].to_i)
  end

  private

  def validate_options
    raise("Options must have source_id key") if @options[:source_id].blank?
  end
end
