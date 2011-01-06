require 'haml/helpers/action_view_mods'
require 'haml/helpers/action_view_extensions'
require 'haml/template'
require 'sass'
require 'sass/plugin'

Haml::Template::options[:format] = :html5

css_dir = Teambox.config.heroku? ? "tmp" : "public"

Sass::Plugin.add_template_location(Rails.root + 'app/styles', Rails.root + css_dir + 'stylesheets')

if Teambox.config.heroku?
  # add Rack middleware to serve compiled stylesheets from "tmp/stylesheets"
  Teambox::Application.config.middleware.delete 'Sass::Plugin::Rack'
  Teambox::Application.config.middleware.insert_after 'ActionDispatch::Static', 'Sass::Plugin::Rack'
  Teambox::Application.config.middleware.insert_after 'Sass::Plugin::Rack', 'Rack::Static',
    :urls => ['/stylesheets'], :root => "#{Rails.root}/tmp"
end
