module OauthClientsHelper
  def new_oauth_client_link
    link_to content_tag(:span,"Register a new app"), new_oauth_client_path, :class => 'add_button'
  end
end