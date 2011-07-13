attributes :id, :description, :user_id, :page_id
attributes :url => :download
extends 'api_v2/shared/type'
code(:slot_id) { |n| n.page_slot.try :id }

attributes :asset_file_name => :filename, :asset_content_type => :mime_type, :asset_file_size => :bytes

