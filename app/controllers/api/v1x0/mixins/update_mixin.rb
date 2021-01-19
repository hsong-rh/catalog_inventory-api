module Api
  module V1x0
    module Mixins
      module UpdateMixin
        def update
          model.update(params.require(:id), params_for_update)
          head :no_content
        end
      end
    end
  end
end
