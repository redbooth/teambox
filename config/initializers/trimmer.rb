require 'trimmer_scope'

trimmer_static_cache_block = Proc.new do |env,res|

    path = Rack::Utils.unescape(env['PATH_INFO'])

    should_cache = case path
    when /\/trimmer(\/([^\/]+))*\/translations\.([js]+)$/
      true
    when /\/trimmer\/([^\/]+)\/templates\.([js]+)$/
      true
    when /\/trimmer\/([^\.|\/]+)\.([js]+)$/
      true
    else
      false
    end
    should_cache = false unless Teambox::Application.config.action_controller.perform_caching
    should_cache
end 

Teambox::Application.config.middleware.use Rack::Staticifier, 
  :root => Teambox.config.trimmer_cache_dir, 
  :cache_if => trimmer_static_cache_block

Teambox::Application.config.middleware.use Trimmer::Controller, 
  :templates_path => Teambox.config.trimmer_templates_dir, 
  :allowed_keys => Teambox.config.trimmer_allowed_keys,
  :renderer_scope => Teambox::Trimmer::RendererScope.new

