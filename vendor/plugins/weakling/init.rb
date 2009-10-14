require 'weakling'

ActionView::Base.class_eval do
  include WeaklingHelper
end

ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'weakling'
