unless defined? Bundler
  require 'rubygems'
  gem 'bundler', '~> 1.0.0.rc'
  require 'bundler'
end

Bundler.setup

module Rails
  # so Rails doesn't think we have an "outdated" boot.rb file
  def self.vendor_rails?() false end
end

RAILS_ROOT = File.expand_path('../..', __FILE__) unless defined?(RAILS_ROOT)

require 'initializer'

Rails::Initializer.class_eval do
  alias old_load_gems load_gems
  # require gems that are Rails plugins
  def load_gems
    Bundler.require(:plugins)
  end
end

Rails::Initializer.run(:set_load_path)
