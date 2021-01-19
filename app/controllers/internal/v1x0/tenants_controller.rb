module Internal
  module V1x0
    class TenantsController < ::ApplicationController
      include Api::V1x0::Mixins::IndexMixin
      include Api::V1x0::Mixins::ShowMixin
    end
  end
end
