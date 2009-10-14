require "fileutils"
include FileUtils::Verbose

RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..")) unless defined?(RAILS_ROOT)

if File.exists?(File.join(RAILS_ROOT, "public", "stylesheets", "sass"))
  cp      File.join(File.dirname(__FILE__), "public", "stylesheets", "fyi.sass"), 
          File.join(RAILS_ROOT, "public", "stylesheets", "sass")
else
  cp      File.join(File.dirname(__FILE__), "public", "stylesheets", "fyi.css"), 
          File.join(RAILS_ROOT, "public", "stylesheets")  
end

if File.exists?(File.join(RAILS_ROOT, "vendor", "sprockets"))
  mkdir_p File.join(RAILS_ROOT, "vendor", "sprockets","fyi", "src")
  cp      File.join(File.dirname(__FILE__), "public", "javascripts", "fyi.js"), 
          File.join(RAILS_ROOT, "vendor", "sprockets","weakling", "src")
else
  cp      File.join(File.dirname(__FILE__), "public", "javascripts", "fyi.js"), 
          File.join(RAILS_ROOT, "public", "javascripts")
end