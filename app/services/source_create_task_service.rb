class SourceCreateTaskService
  def initialize(options)
    @options = options.deep_symbolize_keys
  end

  def process
    Source.create!(source_options)
  end

  def source_options
    # TODO: populate more fields
    {}.tap do |options|
      options[:id] = @options[:source_id]
      options[:uid] = @options[:source_uid]
    end
  end
end
