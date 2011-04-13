module Teambox
  module Trimmer
    class Config
      private
        def method_missing(method, *args)
          Teambox.config.try(method, *args) rescue false ||
            ActionController::Base.config.try(method, *args) rescue false || super(method, *args)
        end
    end

    class RendererScope
      attr_accessor :config, :controller

      include ActionDispatch::Routing::UrlFor
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::TranslationHelper
      include ActionView::Helpers::RawOutputHelper

      def config
        @config ||= Config.new
      end

      def controller
        @controller ||= ActionController::Base.new
      end
    end
  end
end
