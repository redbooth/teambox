class TabnavGenerator < Rails::Generator::Base
  attr_accessor :name

  def initialize(*runtime_args)
    super(*runtime_args)
    if args[0].nil? 
      puts banner
    else
      @name = args[0].underscore
    end
  end
  
  def manifest
    record do |m|
      if @name 
        m.directory File.join('app/views/widgets')
        m.template 'tabnav.rhtml', File.join('app/views/widgets', "_#{@name}_tabnav.rhtml")
      end
    end
  end
  
  protected 
  
  def banner
    IO.read File.expand_path(File.join(File.dirname(__FILE__), 'USAGE')) 
  end
  
end