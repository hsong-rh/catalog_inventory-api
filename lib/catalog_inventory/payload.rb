module CatalogInventory
  class Payload
    attr_accessor :response_format, :upload_url, :jobs, :previous_sha, :previous_size

    def initialize(response_format, upload_url, jobs, previous_sha = nil, previous_size = nil)
      @response_format = response_format
      @jobs = jobs
      @upload_url = upload_url
      @previous_sha = previous_sha
      @previous_size = previous_size
    end
  end
end
