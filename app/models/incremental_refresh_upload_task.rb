class IncrementalRefreshUploadTask < MqttClientTask
  after_update :post_incremental_refresh_upload_task, :if => proc { type == 'IncrementalRefreshUploadTask' && state == 'completed' }

  def post_incremental_refresh_upload_task
    PostRefreshUploadTaskService.new(service_options).process
  end
end
