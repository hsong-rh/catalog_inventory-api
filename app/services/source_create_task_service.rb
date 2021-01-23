class SourceCreateTaskService < TaskService
  def process
    Rails.logger.info("SOURCE TYPE ID #{ClowderConfig.instance["SOURCE_TYPE_ID"]}")
    Rails.logger.info("OPTIONS SOURCE TYPE ID #{@options[:source_type_id]}")
    return if ClowderConfig.instance["SOURCE_TYPE_ID"].blank? || ClowderConfig.instance["SOURCE_TYPE_ID"] != @options[:source_type_id]

    Rails.logger.info("Creating Source")
    Source.create!(source_options)
    Rails.logger.info("Creating Source Finished")
    ActiveRecord::Base.connection().commit_db_transaction unless Rails.env.test?
  end

  private

  def source_options
    {}.tap do |options|
      options[:tenant_id] = tenant.id
      options[:id] = @options[:id]
      options[:uid] = @options[:source_uid]
    end
  end

  def validate_options
    raise("Options must have id") unless @options[:id].present?
  end
end
