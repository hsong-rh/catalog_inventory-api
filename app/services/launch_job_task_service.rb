class LaunchJobTaskService < TaskService
  attr_reader :task

  def initialize(params)
    super
    @service_offering = ServiceOffering.find(params.require(:service_offering_id))
  end

  def process
    @task = LaunchJobTask.create!(task_options)

    self
  end

  private

  def task_options
    {}.tap do |options|
      options[:forwardable_headers] = Insights::API::Common::Request.current_forwardable
      options[:source_id] = source_id
      options[:tenant] = tenant
      options[:state]  = 'pending'
      options[:status] = 'ok'
      options[:input] = task_input
    end
  end

  def response_format
    "json"
  end

  def source_id
    @service_offering.source_id
  end

  def tenant
    @service_offering.tenant
  end

  def jobs
    jobs = []

    launch = CatalogInventory::Job.new
    launch.href_slug = "#{TOWER_API_VERSION}/job_templates/#{@service_offering.source_ref}/launch/"
    launch.method = "launch"
    launch.params = payload_params
    launch.apply_filter = {"id":"id", "status":"status", "started":"started", "url":"url", "type":"type","finished":"finished", "modified":"modified", "description":"description", "extra_vars":"extra_vars", "artifacts":"artifacts", "name":"name","created":"created", "unified_job_template":"unified_job_template"}
    jobs << launch

    jobs
  end

  def payload_params
    {:extra_vars => @params[:service_parameters] || {}}
  end
end