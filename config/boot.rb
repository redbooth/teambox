begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

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
