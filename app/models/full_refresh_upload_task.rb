class FullRefreshUploadTask < CloudConnectorTask
  after_update :post_upload_task, :if => proc { state == 'completed' && (status == 'unchanged' || status == 'error') }

  def post_upload_task
    PostUploadTaskService.new(service_options).process
  end
end
