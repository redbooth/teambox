class Upload < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  file_column :file
  
  TARGET_TYPES = ['Comment','Page','Note','Project','Task','TaskList','User']
  
  validates_each :image_filename do |record, attr, value|
    filename_is_used = Upload.find(:first,:conditions => { :project_id => record.project_id, :image_filename => value })
    if filename_is_used
      record.image_filename = record.unique_filename(value)
    end
  end
  
  acts_as_fleximage do
    image_directory 'public/upload'
    use_creation_date_based_directories false
    invalid_image_message 'format is invalid. You must supply a valid image file.'
    require_image false
    default_image_path 'public/images/person.gif'    
  end
  
  def is_image?
    self.content_type.match(/^image/) != nil
  end
  
  def pathname
    if self.is_image?
      "public/uploads/#{self.id}.png"
    else
      "public/upload/file/#{self.id}/#{self.image_filename}"
    end
  end
  
  def unique_filename(filename)
    extension_part = File.extname(filename)
    file_part = filename[0..-(extension_part.length + 1)]
    
    used = x = 1
    while used != nil
      new_filename = file_part + "_" + x.to_s + extension_part
      used = Upload.find_by_image_filename(new_filename,:conditions => { :project_id => self.project_id })
      x += 1
    end
    new_filename
  end
end