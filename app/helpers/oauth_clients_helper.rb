module OauthClientsHelper
  def new_oauth_client_link
    link_to content_tag(:span,t('oauth_clients.index.register_app')), new_oauth_client_path, :class => 'add_button'
  end
end