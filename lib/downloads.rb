module Downloads

  #include in models
  module Downloadable

  end

  #include in controllers
  module Downloading

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:helper_method, [:downloadable_type, :localized_downloadable_type])
    end

    module InstanceMethods

      def downloadable_type(downloadable = nil)
        downloadable = @upload || @folder if downloadable.nil?
        downloadable.class.name.tableize.singularize
      end

      def localized_downloadable_type(downloadable = nil)
        t "downloadable.type.#{downloadable_type(downloadable)}"
      end

      def download_send_file(downloadable, options = {})
        if !!Teambox.config.amazon_s3
          unless downloadable.asset.exists?(params[:style])
            head(:bad_request)
            raise "Unable to download file"
          end
          redirect_to downloadable.s3_url(params[:style])
        else
          path = downloadable.asset.path(params[:style])
          unless File.exist?(path)
            head(:bad_request)
            raise "Unable to download file"
          end

          mime_type = File.mime_type?(downloadable.asset_file_name)
          mime_type = 'application/octet-stream' if mime_type == 'unknown/unknown'

          send_file_options = {:type => mime_type}.merge(options[:send_file] || {})

          response.headers['Cache-Control'] = 'private, max-age=31557600'
          send_file(path, send_file_options)
        end
      end

    end

  end

end