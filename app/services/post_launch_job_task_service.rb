class PostLaunchJobTaskService < TaskService
  def process
    Rails.logger.info("PostLaunchJob")
    create_service_instance
    ActiveRecord::Base.connection().commit_db_transaction unless Rails.env.test?
    # TODO: Should we raise the Kafka Event here we dont have the task object
    self
  end

  private

  def validate_options
    raise("Options must have source_ref key") if @options[:source_ref].blank?
  end

  def create_service_instance
    instance = ServiceInstance.create!(@options)
    Rails.logger.info("ServiceInstance##{instance.id} is created.")
  end

  # TODO: populate payload
  def kafka_payload
    {:params => {}}
  end
end
