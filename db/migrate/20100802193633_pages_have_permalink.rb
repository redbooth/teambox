class PagesHavePermalink < ActiveRecord::Migration
  def self.up
    add_column :pages, :permalink, :string
  end

  def self.down
    remove_column :pages, :permalink
  end
end
