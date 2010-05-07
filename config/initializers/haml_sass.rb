require 'haml/helpers/action_view_mods'
require 'haml/helpers/action_view_extensions'
require 'haml/template'
require 'sass'
require 'sass/plugin'

Sass::Plugin.options[:template_location] = {
  "#{Rails.root}/app/styles" => Rails.configuration.heroku??
    "#{Rails.root}/tmp/stylesheets" : "#{Rails.root}/public/stylesheets"
}

if Rails.configuration.heroku?
  # add Rack middleware to serve compiled stylesheets from "tmp/stylesheets"
  Rails.configuration.middleware.insert_after 'Sass::Plugin::Rack', 'Rack::Static',
    :urls => ['/stylesheets'], :root => "#{Rails.root}/tmp"
end
