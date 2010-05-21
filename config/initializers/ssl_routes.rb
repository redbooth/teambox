ActionController::Routing::Route.class_eval do
  def optimise_with_ssl?
    optimise_without_ssl? and not ( Teambox.config.secure_logins and
      SslHelper::UrlRewriter.requires_ssl?(requirements.merge(conditions)) )
  end
  alias_method_chain :optimise?, :ssl
end
