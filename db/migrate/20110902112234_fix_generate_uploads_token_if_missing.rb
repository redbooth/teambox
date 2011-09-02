class FixGenerateUploadsTokenIfMissing < ActiveRecord::Migration

  def self.up
    return unless Upload.unscoped.count > 0

    Upload.unscoped.find_each do |upload|
      if upload.token.nil?
        upload.send :generate_token
        upload.update_attribute :token, upload.token
      end
    end
  end

  def self.down
  end
end
