module CatalogInventory
  class Payload
    attr_accessor :response_format, :upload_url, :jobs

    def initialize(response_format, upload_url, jobs, previous_sha = nil, previous_size = nil)
      @response_format = response_format
      @jobs = jobs
      @upload_url = upload_url
      @previous_sha = previous_sha if previous_sha.present?
      @previous_size = previous_size if previous_size.present?
    end
  end
end
