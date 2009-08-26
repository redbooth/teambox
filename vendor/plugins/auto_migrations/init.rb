require 'auto_migrations'
ActiveRecord::Migration.send :include, AutoMigrations
