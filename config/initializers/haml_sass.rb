require 'haml/helpers/action_view_mods'
require 'haml/helpers/action_view_extensions'
require 'haml/template'
require 'sass'
require 'sass/plugin'

Haml::Template::options[:format] = :html5

css_dir = Rails.configuration.heroku? ? "tmp" : "public"

Sass::Plugin.add_template_location(Rails.root + 'app/styles', Rails.root + css_dir + 'stylesheets')

if Rails.configuration.heroku?
  # add Rack middleware to serve compiled stylesheets from "tmp/stylesheets"
  Rails.configuration.middleware.insert_after 'Sass::Plugin::Rack', 'Rack::Static',
    :urls => ['/stylesheets'], :root => "#{Rails.root}/tmp"
end
