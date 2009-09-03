class ActiveRecord::Base
  @@white_list_sanitizer = HTML::WhiteListSanitizer.new
  class << self
    attr_accessor :formatted_attributes
  end

  cattr_reader :white_list_sanitizer

  def self.formats_attributes(*attributes)
    (self.formatted_attributes ||= []).push *attributes
    before_save :format_attributes
    send :include, HtmlFormatting, ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper
  end

end