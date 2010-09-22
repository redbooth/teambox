class Pagepositions < ActiveRecord::Migration
  def self.up
    add_column :pages, :position, :integer
  end

  def self.down
    remove_column :pages, :position
  end
end
