module ActionView
  module Helpers
    module AssetTagHelper
      def javascript_include_tag_with_widgets(*sources)
        javascript_include_tag_without_widgets(*sources)
      end
      alias_method_chain :javascript_include_tag, :widgets 
    end
  end
end