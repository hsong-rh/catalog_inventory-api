class SourceCreateTaskService < TaskService
  def process
    return if ClowderConfig.instance["SOURCE_TYPE_ID"].blank? || ClowderConfig.instance["SOURCE_TYPE_ID"] != @options[:source_type_id].to_s

    Rails.logger.info("Creating Source")
    Source.create!(source_options)
    Rails.logger.info("Creating Source Finished")
    ActiveRecord::Base.connection().commit_db_transaction unless Rails.env.test?
  end

  private

  def source_options
    {}.tap do |options|
      options[:tenant] = Tenant.where(:external_tenant => @options[:tenant]).first
      options[:id] = @options[:id]
      options[:uid] = @options[:source_uid]
    end
  end

  def validate_options
    raise("Options must have id") unless @options[:id].present?
  end
end
