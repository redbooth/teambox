require 'fyi'

ActionView::Base.class_eval do
  include FyiHelper
end

ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'fyi'
