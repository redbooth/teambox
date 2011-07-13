Teambox::Application.config.middleware.use Rack::Staticifier, :root => 'public' do |env, response|
  env['PATH_INFO'].include?('api') && !env['PATH_INFO'].include?('account')
end if Teambox.config.cache_api?
