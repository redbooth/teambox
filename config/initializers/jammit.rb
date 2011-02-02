# I added this to make Jammit compile the assets in production
require 'lib/jammit_loading'

 Sass::Plugin.update_stylesheets
 Jammit.package!
