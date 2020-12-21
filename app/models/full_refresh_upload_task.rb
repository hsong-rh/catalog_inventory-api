class FullRefreshUploadTask < MqttClientTask
  after_update :post_full_refresh_upload_task, :if => proc { type == 'FullRefreshUploadTask' && state == 'completed' }

  def post_full_refresh_upload_task
    PostRefreshUploadTaskService.new(service_options).process
  end

  def service_options
    {}.tap do |options|
      options[:tenant_id] = tenant.id
      options[:source_id] = source.id
    end
  end
end
