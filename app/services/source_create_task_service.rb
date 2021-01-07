class SourceCreateTaskService < TaskService
  def process
    Source.create!(source_options)
  end

  private

  def source_options
    {}.tap do |options|
      options[:tenant_id] = tenant.id
      options[:id] = @options[:source_id]
      options[:uid] = @options[:source_uid]
    end
  end
end
