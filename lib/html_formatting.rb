module HtmlFormatting
  protected
  
  def format_attributes
    self.class.formatted_attributes.each do |attr|
      raw    = read_attribute attr
      textilized = RedCloth.new(raw, [:hard_breaks, :no_span_caps])
      textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      html = textilized.to_html
      linked = auto_link(html) { |text| truncate(text, :length => 40) }
      linked.gsub!(/href=\"www/i) { |s| "href=\"http://www" }
      write_attribute "#{attr}_html", white_list_sanitizer.sanitize(linked)
    end
  end
  
  include ActionView::Helpers::UrlHelper
end