module Widgets
  module CodeHelper
    # es: <%= code 'models/post.rb' %>
    def code file_path, opts = {}
      html = ''
      if opts[:generate_css] == true
        css_template = ERB.new IO.read(File.expand_path(File.dirname(__FILE__) + '/code.css.erb'))
        html << css_template.result(binding)
      end
      
      code = File.read(File.expand_path(File.join(RAILS_ROOT, "app/#{file_path}")))
      convertor = ::Syntax::Convertors::HTML.for_syntax "ruby"
      html << convertor.convert(code)
      html
    end   
  end
end
