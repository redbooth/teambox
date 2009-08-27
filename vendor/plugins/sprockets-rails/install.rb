require "fileutils"
include FileUtils::Verbose

RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..")) unless defined?(RAILS_ROOT)

mkdir_p File.join(RAILS_ROOT, "vendor", "sprockets")
mkdir_p File.join(RAILS_ROOT, "app", "javascripts")
touch   File.join(RAILS_ROOT, "app", "javascripts", "application.js")
cp      File.join(File.dirname(__FILE__), "config", "sprockets.yml"), 
        File.join(RAILS_ROOT, "config")
