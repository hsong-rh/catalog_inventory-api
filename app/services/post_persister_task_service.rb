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
    @options[:task].status == "ok" ? source.update!(ok_options) : source.update!(error_options)

    Rails.logger.info("Source #{source.id}: refresh finished at #{source.refresh_finished_at}, state: #{source.refresh_state}")
  end

  def ok_options
    {:last_successful_refresh_at => @options[:task][:input]["refresh_request_at"],
     :refresh_finished_at        => Time.current,
     :last_refresh_message       => @options[:task][:output],
     :refresh_state              => "Done"}
  end

  def error_options
    {:refresh_finished_at  => Time.current,
     :last_refresh_message => @options[:task][:output][:errors].join("; "),
     :refresh_state        => "Error"}
  end
end
