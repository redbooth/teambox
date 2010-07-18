# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'tolk/tasks'
require 'thinking_sphinx/tasks'

# FIXME: this sucks
task "preload_indexed_models" => :environment do
  require 'role_record'
  require 'project'
  require 'task'
  require 'conversation'
  require 'comment'
  require 'upload'
end
task "thinking_sphinx:configure" => :preload_indexed_models

