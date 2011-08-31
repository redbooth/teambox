class GenerateFolderTokenIfMissing < ActiveRecord::Migration
  def self.up
    return unless Folder.unscoped.count > 0

    Folder.unscoped.find_each do |folder|
      if folder.token.nil?
        folder.send :generate_token
        folder.update_attribute :token, folder.token
      end
    end
  end

  def self.down
  end
end
