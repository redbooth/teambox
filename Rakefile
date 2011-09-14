# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Teambox::Application.load_tasks

# Gem tasks
require 'thinking_sphinx/tasks' if Teambox.config.allow_search
