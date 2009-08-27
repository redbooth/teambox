ActiveRecord::Schema.define(:version => 0) do
  create_table :pages, :force => true do |t|
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :created_on, :datetime
    t.column :updated_on, :datetime
    t.column :author_id, :integer
    t.column :revisor_id, :integer
  end

  create_table :page_versions, :force => true do |t|
    t.column :page_id, :integer
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :created_on, :datetime
    t.column :updated_on, :datetime
    t.column :author_id, :integer
    t.column :revisor_id, :integer
  end
  
  add_index :page_versions, [:page_id, :version], :unique => true
  
  create_table :authors, :force => true do |t|
    t.column :page_id, :integer
    t.column :name, :string
  end
  
  create_table :locked_pages, :force => true do |t|
    t.column :lock_version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :type, :string, :limit => 255
  end

  create_table :locked_pages_revisions, :force => true do |t|
    t.column :page_id, :integer
    t.column :lock_version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :version_type, :string, :limit => 255
    t.column :updated_at, :datetime
  end
  
  add_index :locked_pages_revisions, [:page_id, :lock_version], :unique => true

  create_table :widgets, :force => true do |t|
    t.column :name, :string, :limit => 50
    t.column :foo, :string
    t.column :version, :integer
    t.column :updated_at, :datetime
  end

  create_table :widget_versions, :force => true do |t|
    t.column :widget_id, :integer
    t.column :name, :string, :limit => 50
    t.column :version, :integer
    t.column :updated_at, :datetime
  end
  
  add_index :widget_versions, [:widget_id, :version], :unique => true
  
  create_table :landmarks, :force => true do |t|
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
    t.column :doesnt_trigger_version,:string
    t.column :version, :integer
  end

  create_table :landmark_versions, :force => true do |t|
    t.column :landmark_id, :integer
    t.column :name, :string
    t.column :latitude, :float
    t.column :longitude, :float
    t.column :doesnt_trigger_version,:string
    t.column :version, :integer
  end
  
  add_index :landmark_versions, [:landmark_id, :version], :unique => true
end
