class SourceDestroyTaskService
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  def process
    validate_options
    Source.destroy(@options[:source_id].to_i)
  end

  private

  def validate_options
    raise("Options must have source_id key") if @options[:source_id].blank?
  end
end
