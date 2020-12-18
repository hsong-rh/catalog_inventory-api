class SourceCreateTaskService
  def initialize(options)
    @options = options
  end

  def process
    Source.create!(source_options)
  end

  def source_options
    # TODO: populate more fields
    {}.tap do |options|
      options[:id] = @options[:id]
      options[:uid] = @options[:uid]
      options[:tenant_id] = @options[:tenant_id]
    end
  end
end
