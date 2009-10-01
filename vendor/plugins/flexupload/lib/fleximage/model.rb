module Fleximage
  
  # Container for Fleximage model method inclusion modules
  module Model
    
    class MasterImageNotFound < RuntimeError #:nodoc:
    end
    
    # Include acts_as_fleximage class method
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end
    
    # directory
    # require_image
    # only_images
    # preprocess_image
    
    module ClassMethods
      
      # Use this method to include Fleximage functionality in your model.  It takes an 
      # options hash with a single required key, :+image_directory+.  This key should 
      # point to the directory you want your images stored on your server.  Or
      # configure with a nice looking block.
      def acts_as_fleximage(options = {})
        
        # Include the necesary instance methods
        include Fleximage::Model::InstanceMethods
        
        # Call this class method just like you would call +operate+ in a view.
        # The image transoformation in the provided block will be run on every uploaded image before its saved as the 
        # master image.
        def self.preprocess_image(&block)
          preprocess_image_operation(block)
        end
        
        # validation callback
        #validate :validate_image if respond_to?(:validate)
        
        # Where images get stored
        dsl_accessor :directory
        
        # Require a valid image.  Defaults to true.  Set to false if its ok to have no image for
        dsl_accessor :require_image, :default => false
        
        # Only allow images
        dsl_accessor :only_images, :default => false
              
        dsl_accessor :use_creation_date_based_directories, :default => true
        
        dsl_accessor :default_file_path        
        
        def self.translate_error_message(name, fallback, options = {})
          translation = I18n.translate "activerecord.errors.models.#{self.model_name.underscore}.#{name}", options
          if translation.match /translation missing:/
            I18n.translate "activerecord.errors.messages.#{name}", options.merge({ :default => fallback })
          end
        end

        # A block that processes an image before it gets saved as the master image of a record.
        # Can be helpful to resize potentially huge images to something more manageable. Set via
        # the "preprocess_image { |image| ... }" class method.
        dsl_accessor :preprocess_image_operation
        
        # Image related save and destroy callbacks
        if respond_to?(:before_save)
          after_destroy :delete_image_file
          before_save   :pre_save
          after_save    :post_save
        end
        
        # execute configuration block
        yield if block_given?
        
        # set the image directory from passed options
        directory options[:directory] if options[:directory]
        
        # Require the declaration of a master image storage directory
        if respond_to?(:validate) && !directory
          raise "No place to put images!  Declare this via the :image_directory => 'path/to/directory' option\n"+
                "Or add a database column named image_file_data for DB storage\n"+
                "Or set :virtual to true if this class has no image store at all\n"+
                "Or set a default image to show with :default_image or :default_image_path"
        end
      end
      
      def file_exists(file)
        # File must be a valid object
        return false if file.nil?
        
        # Get the size of the file.  file.size works for form-uploaded images, file.stat.size works
        # for file object created by File.open('foo.jpg', 'rb').  It must have a size > 0.
        return false if (file.respond_to?(:size) ? file.size : file.stat.size) <= 0
        
        # object must respond to the read method to fetch its contents.
        return false if !file.respond_to?(:read)
        
        # file validation passed, return true
        true
      end
    end
    
    # Provides methods that every model instance that acts_as_fleximage needs.
    module InstanceMethods
      
      def directory_path
        raise 'No image directory was defined, cannot generate path' unless self.class.directory
        directory = "#{RAILS_ROOT}/#{self.class.directory}"
        if self.class.use_creation_date_based_directories
          creation = self[:created_at] || self[:created_on]
          "#{directory}/#{creation.year}/#{creation.month}/#{creation.day}"
        else
          directory
        end
      end
      
      def file_extension
        File.extname(self.filename)
      end
      
      def file_path
        "#{directory_path}/#{id}#{file_extension}"
      end
      
      def temp_file_path
        "#{temp_path}/#{@file_temp}"
      end
      
      def file=(file)
        if self.class.file_exists(file)
          if file.respond_to?(:original_filename)
            self.filename = file.original_filename
          else
            self.filename = File.basename(file.path)
          end
          
          self.content_type = get_content_type(file)
          self.filesize = file.size
          
          if self.class.only_images && !self.is_image?
            raise "Expected an image"
          end
          
          @uploaded_file = true
          
          load_file(file.path)
          save_temp_file
        end
      end

      def get_content_type(file)
        if self.filename =~ /\.png$/i
          'image/png'
        elsif self.filename =~ /\.jpe?g$/i
          'image/jpeg'
        elsif self.filename =~ /\.gif$/i
          'image/gif'
        else
          'application/octet-stream'
        end
      end

      def is_image?
        !!(self.content_type =~ /^image/i)
      end
      
      # Call from a .flexi view template.  This enables the rendering of operators 
      # so that you can transform your image.  This is the method that is the foundation
      # of .flexi views.  Every view should consist of image manipulation code inside a
      # block passed to this method. 
      #
      #   # app/views/photos/thumb.jpg.flexi
      #   @photo.operate do |image|
      #     image.resize '320x240'
      #   end
      def operate(&block)
        returning self do
          if self.is_image?
            proxy = ImageProxy.new(load_file(file_path), self)
            block.call(proxy)
            @output_file = proxy.image
          else
            @output_file = File.new(file_path)
          end
        end
      end
      
      # Load the image from disk/DB, or return the cached and potentially 
      # processed output image.
      def load_file(path) #:nodoc:
        unless @output_file
          if self.is_image?
            @output_file ||= Magick::Image.read(path).first
          else
            @output_file ||= File.new(path)
          end
        end
        
        @output_file
      end
      
      # Convert the current output image to a jpg, and return it in binary form.  options support a
      # :format key that can be :jpg, :gif or :png
      def output_file(options = {},debug = false) #:nodoc:
        if @output_file.respond_to?(:to_blob)
          @output_file.strip!
          @output_file.to_blob
        elsif @output_file.respond_to?(:read)
          @output_file.rewind
          @output_file.read
        end
      end
      
      private
        # Perform pre save tasks.  Preprocess the image, and write it to DB.
        def pre_save
          if @uploaded_file && self.class.preprocess_image_operation
            operate(&self.class.preprocess_image_operation)
          end
        end
        
        # Write image to file system and cleanup garbage.
        def post_save
          if @uploaded_file
            # Make sure target directory exists
            FileUtils.mkdir_p(directory_path)
          
            # Write Master Image
            File.open(file_path,'w') do |f|
              f.rewind
              f.write output_file
            end
          
            # Cleanup temp files
            delete_temp_file
          end
        end
        
        # Preprocess this image before saving
        def perform_preprocess_operation
          if self.class.preprocess_image_operation
            operate(&self.class.preprocess_image_operation)
            set_magic_attributes #update width and height magic columns
            @uploaded_image = @output_image
          end
        end
        
        # Save the image in the rails tmp directory
        def save_temp_file
          @file_temp = Time.now.to_f.to_s.sub('.', '_')
          FileUtils.mkdir_p(temp_path)
          File.open(temp_file_path, 'w') do |f|
            f.rewind
            f.write output_file
          end
        end
        
        def temp_path
          "#{RAILS_ROOT}/tmp/fleximage"
        end
        
        # Delete the temp image after its no longer needed
        def delete_temp_file
          FileUtils.rm_rf temp_file_path
        end
        
        # Load the default image, or raise an expection
        def master_image_not_found
          # Load the default image from a path
          if self.class.default_image_path
            @output_image = Magick::Image.read("#{RAILS_ROOT}/#{self.class.default_image_path}").first
          
          # Or create a default image
          elsif self.class.default_image
            x, y = Fleximage::Operator::Base.size_to_xy(self.class.default_image[:size])
            color = self.class.default_image[:color]
            
            @output_image = Magick::Image.new(x, y) do
              self.background_color = color if color && color != :transparent
            end
          
          # No default, not master image, so raise exception
          else
            message = "Master image was not found for this record"
            
            if !self.class.db_store?
              message << "\nExpected image to be at:"
              message << "\n  #{file_path}"
            end
            
            raise MasterImageNotFound, message
          end
        ensure
          @output_image.dispose! if @output_image
          GC.start
        end
    end
    
  end
end
