class MailView
  class Mapper
    def initialize(app, controller, prefix = "/mail_view")
      @app        = app
      @controller = controller.respond_to?(:name) ? controller.name : controller.to_s
      @prefix     = Regexp.compile("^#{prefix}")
    end

    def call(env)
      if env["PATH_INFO"].to_s =~ @prefix
        env["SCRIPT_NAME"] = $&
        env["PATH_INFO"]   = $'

        @controller.constantize.call(env)
      else
        @app.call(env)
      end
    end
  end
end
