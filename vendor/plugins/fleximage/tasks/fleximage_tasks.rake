namespace :fleximage do
  
  # Find the model class
  def model_class
    raise 'You must specify a FLEXIMAGE_CLASS=MyClass' unless ENV['FLEXIMAGE_CLASS']
    @model_class ||= ENV['FLEXIMAGE_CLASS'].camelcase.constantize
  end
  
  desc "Populate width and height magic columns from the current image store.  Useful when migrating from on old installation."
  task :dimensions => :environment do
    model_class.find(:all).each do |obj|
      if obj.has_image?
        img = obj.load_image
        obj.update_attribute :image_width,  img.columns if obj.respond_to?(:image_width=)
        obj.update_attribute :image_height, img.rows    if obj.respond_to?(:image_height=)
      end
    end
  end
  
  namespace :convert do
        
    def convert_directory_format(to_format)
      model_class.find(:all).each do |obj|
        
        # Get the creation date
        creation = obj[:created_at] || obj[:created_on]
        
        # Generate both types of file paths
        flat_path   = "#{RAILS_ROOT}/#{model_class.image_directory}/#{obj.id}.#{model_class.image_storage_format}"
        nested_path = "#{RAILS_ROOT}/#{model_class.image_directory}/#{creation.year}/#{creation.month}/#{creation.day}/#{obj.id}.#{model_class.image_storage_format}" 
        
        # Assign old path and new path based on desired directory format
        if to_format == :nested
          old_path = flat_path
          new_path = nested_path
        else
          old_path = nested_path
          new_path = flat_path
        end
        
        # Move the files
        if old_path != new_path && File.exists?(old_path)
          FileUtils.mkdir_p(File.dirname(new_path))
          FileUtils.move old_path, new_path
          puts "#{old_path} -> #{new_path}"
        end
      end
    end
    
    def convert_image_format(to_format)
      model_class.find(:all).each do |obj|
        
        # convert DB stored images
        if model_class.db_store?
          if obj.image_file_data && obj.image_file_data.any?
            begin
              image = Magick::Image.from_blob(obj.image_file_data).first
              image.format = to_format.to_s.upcase
              obj.image_file_data = image.to_blob
              obj.save
            rescue Exception => e
              puts "Could not convert image for #{model_class} with id #{obj.id}\n  #{e.class} #{e}\n"
            end
          end
        
        # Convert file system stored images
        else        
          # Generate both types of file paths
          png_path = obj.file_path.gsub(/\.jpg$/, '.png')
          jpg_path = obj.file_path.gsub(/\.png$/, '.jpg')
        
          # Output stub
          output = (to_format == :jpg) ? 'PNG -> JPG' : 'JPG -> PNG'
        
          # Assign old path and new path based on desired image format
          if to_format == :jpg
            old_path = png_path
            new_path = jpg_path
          else
            old_path = jpg_path
            new_path = png_path
          end
        
          # Perform conversion
          if File.exists?(old_path)
            image = Magick::Image.read(old_path).first
            image.format = to_format.to_s.upcase
            image.write(new_path)
            File.delete(old_path)
          
            puts "#{output} : Image #{obj.id}"
          end
        end
      end
    end
    
    def ensure_db_store
      col = model_class.columns.find {|c| c.name == 'image_file_data'}
      unless col && col.type == :binary
        raise "No image_file_data field of type :binary for this model!"
      end
    end
    
    desc "Convert a flat images/123.png style image store to a images/2007/11/12/123.png style.  Requires FLEXIMAGE_CLASS=ModelName"
    task :to_nested => :environment do
      convert_directory_format :nested
    end
    
    desc "Convert a nested images/2007/11/12/123.png style image store to a images/123.png style.  Requires FLEXIMAGE_CLASS=ModelName"
    task :to_flat => :environment do
      convert_directory_format :flat
    end
    
    desc "Convert master images stored as JPGs to PNGs"
    task :to_png => :environment do
      convert_image_format :png
    end
    
    desc "Convert master images stored as PNGs to JPGs"
    task :to_jpg => :environment do
      convert_image_format :jpg
    end
    
    desc "Convert master image storage to use the database.  Loads all file-stored images into the database."
    task :to_db => :environment do
      ensure_db_store
      model_class.find(:all).each do |obj|
        if File.exists?(obj.file_path)
          File.open(obj.file_path, 'rb') do |f|
            obj.image_file_data = f.read
            obj.save
          end
        end
      end
      
      puts "--- All images successfully moved to the database.  Check to make sure the transfer worked cleanly before deleting your file system image store."
    end
    
    desc "Convert master image storage to use the file system.  Loads all database images into files."
    task :to_filestore => :environment do
      ensure_db_store
      model_class.find(:all).each do |obj|
        if obj.image_file_data && obj.image_file_data.any?
          File.open(obj.file_path, 'wb+') do |f|
            f.write obj.image_file_data
          end
        end
      end
      
      puts "--- All images successfully moved to the file system.  Remember to remove your image_file_data field from your models database table."
    end
    
  end
end
