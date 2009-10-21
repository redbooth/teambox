require 'rake'
require 'rbconfig'

class ViewSpecifyGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      files = FileList["app/views/**/*.html.erb"]
      
      files.each do |view_template_path|
        next if view_template_path =~ /\/_/  # ignore partials
        
        root_directory = ''
        root_depth = view_template_path.split('/').size - 2
        root_depth.times do
          root_directory += '/..'
        end
        view_template_path =~ /app\/views\/(.*?)\.html\.erb/
        view_template_path_stem = $1  # grab the 'controller/action' part of the path
        view_spec_path = "spec/views/#{view_template_path_stem}.html.erb_spec.rb"
        
        @mocks, @template_stubs = [], []
        File.open(view_template_path) do |f|
          f.each_line do |line|
            @mocks << instance_vars(line)
            @template_stubs << helper_method_names(line)
          end
        end
        
        mocks_and_stubs = (@mocks + @template_stubs).flatten.uniq.sort.join("\n    ")
        
        m.directory File.dirname(view_spec_path)
        m.template 'view_spec.rb', view_spec_path, :assigns => { :view_template_path_stem => view_template_path_stem, :mocks_and_stubs => mocks_and_stubs, :root_directory => root_directory }
      end
    end
  end
  
  protected
  
  def banner
    "Usage: #{$0} [options]"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'

    opt.on("", "--stubs=stub1,stub2,stub3", String,
          "Extra template stubs to add, comma-delimited",
          "Default: none") { |v| options[:stubs] = v.split(',') }             
  end
  
  private
  
  def extra_stubs
    options[:stubs].blank? ? [] : options[:stubs]
  end

  def instance_vars(line)
    returning [] do |mocks|
      line.scan(/@(.+?)\b/).flatten.each do |var|
        begin
          var.classify.constantize
          
          if var.singularize == var
            mocks << "assigns[:#{var}] = mock_model(#{var.classify}, :null_object => true)"
          else
            mocks << "assigns[:#{var}] = [mock_model(#{var.classify}, :null_object => true)].paginate"                            
          end
        rescue NameError
          mocks << "assigns[:#{var}] = mock('#{var}', :null_object => true)"
        end
      end
    end
  end
  
  def helper_method_names(line)
    stubs = []
    helper_methods.each do |helper_method|
      stubs << "template.stub!(:#{helper_method}).and_return(mock('#{helper_method}_return_value', :null_object => true))" if line[helper_method]
    end
    routes.each do |route|
      stubs << "template.stub!(:#{route}).and_return('')" if line[route]
    end
    stubs
  end
  
  def helper_methods
    helper_files = FileList["app/helpers/*.rb"]
    helper_files += FileList["vendor/plugins/**/*_helper.rb"]
    @helper_methods ||= helper_files.collect do |helper_file|
      File.open(helper_file) { |f| f.readlines.join.scan(/def\s+(.+)[(\b]/) }
    end.flatten + extra_stubs
  end
  
  def routes
    unless @routes
      @routes = []
      ActionController::Routing::Routes.routes.collect do |route|
        stem = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
        next if stem.blank?
      
        @routes << "#{stem}_path"
        @routes << "#{stem}_url"
      end
    end
    
    return @routes
  end
end

