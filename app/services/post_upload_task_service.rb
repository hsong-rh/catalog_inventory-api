class PostUploadTaskService < TaskService
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
    case @options[:task].status
    when "unchanged"
      @source.update!(unchanged_options)
    when "error"
      @source.update!(error_options)
    else
      Rails.logger.warn("#{@options[:tasks]} is unhandled")
    end

    Rails.logger.info("Source #{@source.id}: refresh finished at #{@source.refresh_finished_at}, state: #{@source.refresh_state}, message: #{@source.last_refresh_message}")
  end

  def unchanged_options
    {:refresh_finished_at  => Time.current,
     :last_refresh_message => @options[:task].message,
     :refresh_state        => "Done"}
  end

  def error_options
    {:refresh_finished_at  => Time.current,
     :last_refresh_message => @options[:task][:output]["errors"].join("\n"),
     :refresh_state        => "Error"}
  end
end
