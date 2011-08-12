class GenerateUploadTokensIfMissing < ActiveRecord::Migration

  def self.up
    return unless Upload.count > 0

    class Upload
      def gen_token
        # Access private method
        generate_token
      end
    end

    Upload.find_each do |upload|
      if upload.token.nil?
        upload.gen_token
        upload.update_attribute :token, upload.token
      end
    end
  end

  def self.down
  end

end
