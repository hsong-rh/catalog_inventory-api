module Api
  module V1x0
    class TagsController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin
    end
  end
end
