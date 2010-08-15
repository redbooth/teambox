class AddLogoAndParanoidToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :deleted_at, :datetime
    add_column :organizations, :logo_file_name, :string
    add_column :organizations, :logo_content_type, :string
    add_column :organizations, :logo_file_size, :integer
  end

  def self.down
    remove_column :organizations, :deleted_at
    remove_column :organizations, :logo_file_name
    remove_column :organizations, :logo_content_type
    remove_column :organizations, :logo_file_size
  end
end
