module Fleximage
  
  # Renders a .flexi template
  class LegacyView #:nodoc:
    class TemplateDidNotReturnImage < RuntimeError #:nodoc:
    end
    
    def initialize(view)
      @view = view
    end
    
    def render(template, local_assigns = {})
      # process the view
      result = @view.instance_eval do
        
        # Shorthand color creation
        def color(*args)
          if args.size == 1 && args.first.is_a?(String)
            args.first
          else
            Magick::Pixel.new(*args)
          end
        end
        
        # inject assigns into instance variables
        assigns.each do |key, value|
          instance_variable_set "@#{key}", value
        end
        
        # inject local assigns into reader methods
        local_assigns.each do |key, value|
          class << self; self; end.send(:define_method, key) { value }
        end
        
        #execute the template
        eval(template)
      end
      
      # Raise an error if object returned from template is not an image record
      unless result.class.include?(Fleximage::Model::InstanceMethods)
        raise TemplateDidNotReturnImage, ".flexi template was expected to return a model instance that acts_as_fleximage, but got an instance of <#{result.class}> instead."
      end
      
      # Figure out the proper format
      requested_format = (@view.params[:format] || :jpg).to_sym
      raise 'Image must be requested with an image type format.  jpg, gif and png only are supported.' unless [:jpg, :gif, :png].include?(requested_format)
      
      # Set proper content type
      @view.controller.headers["Content-Type"] = Mime::Type.lookup_by_extension(requested_format.to_s).to_s
      
      # get rendered result
      rendered_image = result.output_image(:format => requested_format)
      
      # Return image data
      return rendered_image
    ensure
    
      # ensure garbage collection happens after every flex image render
      rendered_image.dispose!
      GC.start
    end
  end
end
