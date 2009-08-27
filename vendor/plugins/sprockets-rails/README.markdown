`sprockets-rails`
=================

The `sprockets-rails` plugin sets up your Rails application for use with [Sprockets](http://github.com/sstephenson/sprockets). To install it, first install the `sprockets` RubyGem, then check out a copy of the `sprockets-rails` repository into your `vendor/plugins/` directory. When you run the bundled `install.rb` script, `sprockets-rails` will create two new directories in your application and copy a configuration file into your `config/` directory.

`sprockets-rails` includes a controller named `SprocketsController` that renders your application's Sprockets concatenation. When caching is enabled, e.g. in production mode, `SprocketsController` uses Rails page caching to save the concatenated output to `public/sprockets.js` the first time it is requested. When caching is disabled, e.g. in development mode, `SprocketsController` will render a fresh concatenation any time a source file changes.

To source Sprockets' JavaScript concatenation from your HTML templates, use the provided `sprockets_include_tag` helper.

`sprockets-rails` also includes a set of Rake tasks for generating the concatenation (`rake sprockets:install_script`) and installing provided assets (`rake sprockets:install_assets`). Run `sprockets:install_assets` any time you add or update a Sprockets plugin in your application. Add `sprockets:install_script` as a [Capistrano](http://www.capify.org/) post-deploy hook to generate the Sprockets concatenation on your servers automatically at deploy time.

Here's a walkthrough of the installation process:

1. `gem install --remote sprockets`

2. `script/plugin install git://github.com/sstephenson/sprockets-rails.git`

    You now have `app/javascripts/` and `vendor/sprockets/` directories in your application, as well as a `config/sprockets.yml` file.

3. Edit your `config/routes.rb` file to add routes for `SprocketsController`:

        ActionController::Routing::Routes.draw do |map|
          # Add the following line:
          SprocketsApplication.routes(map) 
          ...
        end

4. Move your JavaScript source files from `public/javascripts/` into `app/javascripts/`. All files in all subdirectories of `app/javascripts/` will be required by Sprockets in alphabetical order, with the exception of `app/javascripts/application.js`, which is required _before any other file_. (You can change this behavior by editing the `source_files` line of `config/sprockets.yml`.)

5. Adjust your HTML templates to call `<%= sprockets_include_tag %>` instead of `<%= javascript_include_tag ... %>`.

Once `sprockets-rails` is installed, you can check out Sprockets plugins into the `vendor/sprockets/` directory. By default, `sprockets-rails` configures Sprockets' load path to search `vendor/sprockets/*/src/`, as well as `vendor/plugins/*/javascripts/`. This means that the `javascripts/` directories of Rails plugins are automatically installed into your Sprockets load path.

## License

Copyright &copy; 2009 Sam Stephenson.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
