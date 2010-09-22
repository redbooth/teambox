# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register_alias "text/html", :m
Mime::Type.register_alias "text/html", :print

# teach `respond_to` in the controller that we want mobile requests
# to fall back to "html" block if the "m" block itself wasn't defined
ActionController::MimeResponds::Responder.class_eval do
  def initialize_with_mobile(controller)
    initialize_without_mobile(controller)
    
    if @mime_type_priority.eql? [Mime::M]
      @mime_type_priority << Mime::HTML
    end
  end
  
  alias_method_chain :initialize, :mobile
  
  def html(&block)
    mime_type = Mime::HTML
    @order << mime_type

    @responses[mime_type] ||= Proc.new do
      @response.template.template_format = (@request.format == :m ? @request.format : mime_type).to_sym
      @response.content_type = mime_type.to_s
      if block_given?
        block.call
      else
        @controller.send(:render, :action => @controller.action_name)
      end
    end
  end
end
