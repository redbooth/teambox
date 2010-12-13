module SslHelper
  def self.included(base)
    if base.respond_to? :before_filter
      base.class_eval do
        include ControllerMethods
        extend ControllerHelpers
      end
    end
  end
  
  module ControllerHelpers
    def force_ssl(options = {})
      before_filter :redirect_to_https, options
    end
  end
  
  module ControllerMethods
    def redirect_to_https
      if Teambox.config.secure_logins and not request.ssl?
        redirect_to :protocol => 'https'
      end
    end
    
    private
    def initialize_current_url
      @url = ::SslHelper::UrlRewriter.new(request, params.clone)
    end
  end
  
  class UrlRewriter < ActionController::UrlRewriter
    SSL_ACTIONS = [
      { :controller => 'sessions', :action => 'new' },
      { :controller => 'sessions', :action => 'show' },
      { :controller => 'users', :action => 'new' },
      { :controller => 'users', :action => 'create' },
      { :controller => 'users', :action => 'edit', :sub_action => 'settings' },
      { :controller => 'reset_passwords', :action => 'reset' },
      { :controller => 'reset_passwords', :action => 'update_after_forgetting' }
    ]
    
    def rewrite(options = {})
      if self.class.requires_ssl?(options) and options[:protocol].nil? and Teambox.config.secure_logins
        options = options.merge(:protocol => default_protocol(options))
        options[:only_path] = false if options[:protocol] != @request.protocol
      end
      super(options)
    end
    
    def self.requires_ssl?(options)
      SSL_ACTIONS.include? options.slice(:controller, :action, :sub_action)
    end
    
    private
    
    def default_protocol(options)
      options = @request.symbolized_path_parameters.merge options.symbolize_keys
      options.update options[:params].symbolize_keys if options[:params]
      self.class.requires_ssl?(options) ? 'https' : 'http'
    end
  end
  
  module Routes
    def requires_ssl?
      UrlRewriter.requires_ssl?(requirements.merge(conditions))
    end
  end
  # RAILS3 Fixme
  # class Optimiser < ActionDispatch::Routing::Optimisation::PositionalArguments
  #   def guard_conditions
  #     super.tap do |cond|
  #       if Teambox.config.secure_logins
  #         cond << "#{route.requires_ssl?? '' : '!'}request.ssl?"
  #       end
  #     end
  #   end
  # end
end
