module CatalogInventory
  module Exceptions
    class RecordLockedException          < StandardError; end
    class RefreshAlreadyRunningException < StandardError; end
  end
end
