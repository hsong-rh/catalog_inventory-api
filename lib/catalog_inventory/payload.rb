module CatalogInventory
  class Payload
    attr_accessor :response_format, :upload_url, :jobs

    def initialize(response_format, upload_url, jobs)
      @response_format = response_format
      @jobs = jobs
      @upload_url = upload_url
    end
  end
end
