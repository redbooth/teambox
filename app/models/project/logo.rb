class Project
  #has_attached_file :logo,
  #  :url  => "/project_logos/:id/:style/:basename.:extension",
  #  :path => ":rails_root/public/project_logos/:id/:style/:basename.:extension",
  #  :styles => { :general => "278x500>" }
  #
  #validates_attachment_presence :logo, :unless => Proc.new { |user| user.new_record? }
  #validates_attachment_size :logo, :less_than => 2.megabytes
  #validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png']
end