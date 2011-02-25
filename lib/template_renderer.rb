require "action_view"
 
class TemplateRenderer

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  default_url_options[:host] = Teambox.config.app_domain

  def self.url_for(opts=nil, options=nil)
    unless opts.is_a?(Hash)
      if options[:only_path]
        self.new.polymorphic_path(opts)
      else
        self.new.polymorphic_url(opts)
      end
    else
      self.new.url_for(opts)
    end
  end

  def self.render_template(*args)
    begin
      template.render(*args)
    rescue => err
      Rails.logger.error "EXCEPTION: #{err.message} Trace: #{err.backtrace.join("\n")}"
      Rails.logger.error "EXCEPTION: #{err.sub_template_message}" if err.respond_to?(:sub_template_message)
      Rails.logger.error "EXCEPTION: ANNOTATED SOURCE CODE: #{err.annoted_source_code}" if err.respond_to?(:annoted_source_code)
    end
  end

  private
  def self.template
    unless @template
      @controller = ApplicationController.new
      @controller.request = ActionDispatch::TestRequest.new('HTTPS' => (Teambox.config.secure_logins ? 'on' : 'off'))
      @controller.request.host = Teambox.config.app_domain
      @controller.send("current_user=", User.current)

      @template = ActionView::Base.new(ActionController::Base.view_paths, {}, @controller)
      @template.extend ApplicationController._helpers
      @template.class_eval do
        include Rails.application.routes.url_helpers
      end
    end
    @template
  end
end

