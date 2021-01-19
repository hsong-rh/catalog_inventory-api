module Api
  module V1x0
    class TaggingsController < ApplicationController
      include Mixins::IndexMixin
      include Insights::API::Common::TaggingMethods

      # Present these as tags
      private_class_method def self.api_doc_definition
        @api_doc_definition ||= api_doc.definitions["Tag"]
      end

      def self.presentation_name
        "Tag".freeze
      end

      private

      def model
        primary_collection_model.tagging_relation_name.to_s.singularize.classify.safe_constantize
      end

      def extra_filter_attributes
        {"namespace" => {"type" => "string"}, "name" => {"type" => "string"}, "value" => {"type" => "string"}}
      end
    end
  end
end
