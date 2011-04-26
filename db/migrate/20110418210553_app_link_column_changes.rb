class AppLinkColumnChanges < ActiveRecord::Migration
  def self.up
    add_column :app_links, :credentials, :text

    # Serialize credentials, since they might be given in different format depending on the provider
    AppLink.find_each do |app_link|
      credentials = {}
      credentials['token'] = app_link[:access_token]  if app_link[:access_token]
      credentials['secret'] = app_link[:access_secret] if app_link[:access_secret]
      app_link.credentials = credentials
      app_link.save
    end

    remove_column :app_links, :access_token
    remove_column :app_links, :access_secret
  end

  def self.down
    add_column :app_links, :access_token, :string
    add_column :app_links, :access_secret, :string

    AppLink.find_each do |app_link|
      if app_link.credentials
        app_link[:access_token]  = app_link.credentials['token'] if app_link.credentials.has_key?('token')
        app_link[:access_secret] = app_link.credentials['secret'] if app_link.credentials.has_key?('secret')
      end
      app_link.save
    end

    remove_column :app_links, :credentials
  end
end
