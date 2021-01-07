class PostPersisterTaskService < TaskService
  def process
    update_source
    self
  end

  private

  def validate_options
    super
    raise("Options must have task key") if @options[:task].blank?
  end

  def update_source
    source = Source.find(@options[:task].source_id)
    source.update!(:last_successful_refresh_at => @options[:task][:input]["refresh_request_at"]) if @options[:task].status == "ok"
  end
end
