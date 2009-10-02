module Fleximage
  
  # Renders a .flexi template
  class View < ActionView::TemplateHandler #:nodoc:
    class TemplateDidNotReturnImage < RuntimeError #:nodoc:
    end
    
    def self.call(template)
      "Fleximage::View.new(self).render(template)"
    end

    def initialize(action_view)
      @view = action_view
    end
    
    def render(template)
      # process the view
      result = @view.instance_eval do
        
        # Shorthand color creation
        def color(*args)
          Fleximage::Operator::Base.color(*args)
        end
        
        #execute the template
        eval(template.source)
      end
      
      # Raise an error if object returned from template is not an image record
      unless result.class.include?(Fleximage::Model::InstanceMethods)
        raise TemplateDidNotReturnImage, 
                ".flexi template was expected to return a model instance that acts_as_fleximage, but got an instance of <#{result.class}> instead."
      end
      
      # Set proper content type
      @view.controller.response.content_type = result.content_type
      
      unless result.is_image?
        escaped_filename = result.filename.gsub(/\\/,"\\\\")
        escaped_filename.gsub!(/"/,'\\"')
        @view.controller.response.headers['Content-Disposition'] = "attachment; filename=\"#{escaped_filename}\""
      else
        @view.controller.response.headers['Content-Disposition'] = "inline"
      end
      
      # Set proper caching headers
      if defined?(Rails) && Rails.env == 'production'
        @view.controller.response.headers['Cache-Control'] = 'public, max-age=86400'
      end
      
      # return rendered result
      return result.output_file
    ensure
    
      # ensure garbage collection happens after every flex image render
      GC.start
    end
  end
end
