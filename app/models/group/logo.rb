class Group
  has_attached_file :logo,
    :styles => { 
      :top => ["134x24>", :jpg],
      :icon => ["96x72>", :png] },
    :url  => "/logos/:id/:style.:extension",
    :path => ":rails_root/public/logos/:id/:style.:extension"
    
  def has_logo?
    !logo.original_filename.nil?
  end
end