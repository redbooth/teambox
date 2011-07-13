attributes :id, :description, :download, :user_id
extends 'api_v2/shared/type'

attributes :asset_file_name => :filename, :asset_content_type => :mime_type, :asset_file_size => :bytes

