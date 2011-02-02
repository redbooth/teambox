# I added this to make Jammit compile the assets in production
require 'lib/jammit_loading'

Sass::Plugin.update_stylesheets
if Teambox.config.heroku?
  Teambox::Application.config.middleware.insert_after 'Sass::Plugin::Rack', 'Rack::Static', :urls => ['/jammit'], :root => "#{Rails.root}/tmp/"


  #We need this to make Jammit work on Heroku, it replaces public for tmp in the config that gets from the assets.yml

  Jammit.module_eval do

    def self.load_configuration(config_path, soft=false)
      exists = config_path && File.exists?(config_path)
      return false if soft && !exists
      raise ConfigurationNotFound, "could not find the \"#{config_path}\" configuration file" unless exists
      conf = YAML.load(ERB.new(File.read(config_path)).result)
      conf["stylesheets"]=Hash[conf["stylesheets"].map{|k,v| [k, v.map{|el| el.sub "public","tmp"}] if v.is_a? Array}]
      @config_path            = config_path
      @configuration          = symbolize_keys(conf)
      @package_path           = conf[:package_path] || DEFAULT_PACKAGE_PATH
      @embed_assets           = conf[:embed_assets] || conf[:embed_images]
      #We need not to override compress_assets wrongly relying on the check_java_version cached value
      @compress_assets        = !(conf[:compress_assets] == false) if @compress_assets.nil?
      @gzip_assets            = !(conf[:gzip_assets] == false)
      @allow_debugging        = !(conf[:allow_debugging] == false)
      @mhtml_enabled          = @embed_assets && @embed_assets != "datauri"
      @compressor_options     = symbolize_keys(conf[:compressor_options] || {})
      @css_compressor_options = symbolize_keys(conf[:css_compressor_options] || {})
      set_javascript_compressor(conf[:javascript_compressor])
      set_package_assets(conf[:package_assets])
      set_template_function(conf[:template_function])
      set_template_namespace(conf[:template_namespace])
      set_template_extension(conf[:template_extension])
      symbolize_keys(conf[:stylesheets]) if conf[:stylesheets]
      symbolize_keys(conf[:javascripts]) if conf[:javascripts]
      check_java_version
      check_for_deprecations
      self
    end

  end

  #We reload the config to get the tmp paths

  Jammit.load_configuration Jammit.config_path
  Jammit.package! :output_folder => Rails.root.to_s + "/tmp/jammit"

else
  Jammit.package!
end

