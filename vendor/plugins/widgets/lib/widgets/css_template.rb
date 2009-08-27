module Widgets
  # Utility module for widgets that need to create a default CSS
  # you have to include it inside a Widget to add css_generation capability
  module CssTemplate
   # render and cache the default css 
    def default_css
      @default_css if @default_css
      # if not cache read and evaluate the template
      css_template = ERB.new IO.read(File.expand_path(File.dirname(__FILE__) + '/' + css_template_filename))
      @default_css = css_template.result(binding)
    end
    
    # return the name of the erb to parse for the default css generation
    # (removes namespaces if present)
    # es: in Tabnav #=> 'tabnav.css.erb'
    #        Foo::Bar #=> 'bar.css.erb'
    def css_template_filename
      self.class.name.downcase.gsub(/.*::/,'') << '.css.erb' 
    end
    
    # should the helper generate a css for this tabnav?
    def generate_css?
      @generate_css ? true : false
    end
    
  end
end