# patch for Rails 2.3.9 (ticket #5581)
affected = %w[ActiveRecord::SessionStore ActionController::Session::MemCacheStore]

target = Rails.configuration.middleware.detect do |mid|
  mid.klass.is_a? Class and affected.include? mid.klass.to_s
end

if target
  class RailsCookieMonster
    def initialize(app)
      @app = app
    end
  
    def call(env)
      # monster MUST HAVE COOKIES om nom nom nom
      env['HTTP_COOKIE'] ||= ""
      @app.call(env)
    end
  end

  Rails.configuration.middleware.insert_before target, RailsCookieMonster
end
