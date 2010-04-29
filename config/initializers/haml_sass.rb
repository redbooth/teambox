require 'haml/helpers/action_view_mods'
require 'haml/helpers/action_view_extensions'
require 'haml/template'
require 'sass'
require 'sass/plugin'

Sass::Plugin.options[:template_location] = {
  "#{Rails.root}/app/styles" => ENV['HEROKU_TYPE'] ?
    "#{Rails.root}/tmp/stylesheets" : "#{Rails.root}/public/stylesheets"
}

if ENV['HEROKU_TYPE']
  # add Rack middleware to serve compiled stylesheets from "tmp/stylesheets"
  config.middleware.insert_after 'Sass::Plugin::Rack', 'Rack::Static',
    :urls => ['/stylesheets'], :root => "#{Rails.root}/tmp"
end
