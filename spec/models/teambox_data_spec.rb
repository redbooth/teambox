require 'spec_helper'
describe TeamboxData do
  before do
    Teambox.config.delay_data_processing = false
  end
  
  describe "unserialize" do
    it "should unserialize data" do
      make_the_teambox_dump
      data = dump_test_data
      old_user_count = User.count
      
      Project.destroy_all
      Organization.destroy_all
      
      Project.count.should == 0
      Organization.count.should == 0
      
      TeamboxData.new.tap{|d| d.data = data }.unserialize({}, {:create_organizations => true})
      
      Organization.count.should == 1
      Project.count.should == 1
    end
    
    it "should map existing data where specified" do
      make_the_teambox_dump
      data = dump_test_data
      
      user_list = User.all.map(&:login)
      org_list = Organization.all.map(&:permalink)
      
      Project.destroy_all
      Organization.destroy_all
      User.destroy_all
      
      organization = Factory(:organization)
      user = Factory(:user)
      organization.add_member(user, Membership::ROLES[:admin])
      project = Factory(:project, :organization => organization, :user => user)
      
      user_map = user_list.inject({}){|a,key| a[key] = user.login; a}
      org_map = org_list.inject({}){|a,key| a[key] = organization.permalink; a}
      
      TeamboxData.new.tap{|d| d.data = data; d.user = user }.unserialize(
        {'User' => user_map, 'Organization' => org_map}, {})
      
      Organization.count.should == 1
      Project.count.should == 2
      User.count.should == 1
      
      Project.all.each {|p| p.user.should == user}
      Conversation.all.each {|c| c.user.should == user}
      Comment.all.each {|c| c.user.should == user}
    end
    
    it "should create users when specified" do
      make_the_teambox_dump
      data = dump_test_data
      old_user_count = User.count
      old_project_count = Project.count
      
      User.destroy_all
      Project.destroy_all
      Organization.destroy_all
      
      User.count.should == 0
      Project.count.should == 0
      Organization.count.should == 0
      
      TeamboxData.new.tap{|d| d.data = data }.unserialize({}, {:create_users => true, :create_organizations => true})
      
      User.count.should == old_user_count
      Project.count.should == old_project_count
    end
    
    it "should rollback changes if an error occurs" do
      data = File.open("#{Rails.root}/spec/fixtures/teamboxdump_invalid.json", 'r') do |file|
        ActiveSupport::JSON.decode(file.read)
      end
      
      User.destroy_all
      Project.destroy_all
      Organization.destroy_all
      
      User.count.should == 0
      Project.count.should == 0
      Organization.count.should == 0
      
      begin
        TeamboxData.new.tap{|d| d.data = data }.unserialize({}, {:create_users => true, :create_organizations => true})
      rescue => e
        e.to_s.match(/Validation failed:/).should_not == nil
      end
      
      User.count.should == 0
      Project.count.should == 0
      Organization.count.should == 0
      Activity.count.should == 0
    end
    
    it "should preserve created_at dates" do
      data = File.open("#{Rails.root}/spec/fixtures/teamboxdump.json", 'r') do |file|
        ActiveSupport::JSON.decode(file.read)
      end
      
      User.destroy_all
      Project.destroy_all
      Organization.destroy_all
      
      User.count.should == 0
      Project.count.should == 0
      Organization.count.should == 0
      
      TeamboxData.new.tap{|d| d.data = data }.unserialize({}, {:create_users => true, :create_organizations => true})
      
      Comment.all.each {|o| o.created_at.year.should == 2009}
      Project.all.each {|o| o.created_at.year.should == 2009}
      Task.all.each {|o| o.created_at.year.should == 2009}
      TaskList.all.each {|o| o.created_at.year.should == 2009}
      Conversation.all.each {|o| o.created_at.year.should == 2009}
    end
    
    it "should unserialize a basecamp dump" do
      User.count.should == 0
      Project.count.should == 0
      Organization.count.should == 0
      Conversation.count.should == 0
      TaskList.count.should == 0
      Task.count.should == 0
      Comment.count.should == 0
      Activity.count.should == 0
      
      data = File.open("#{Rails.root}/spec/fixtures/campdump.xml") { |f| Hash.from_xml f.read }
      TeamboxData.new.tap{|d| d.service = 'basecamp'; d.data = data }.unserialize({}, {:create_users => true, :create_organizations => true})
      
      User.count.should == 1
      Project.count.should == 1
      Organization.count.should == 1
      Conversation.count.should == 1
      TaskList.count.should == 2
      Task.count.should == 4
      Comment.count.should == 8
      
      org = Organization.last
      org.memberships.count.should == 1
      org.projects.count.should == 1
      org.projects.first.people.count.should == 1
      
      Task.all.map(&:assigned).should == [Person.first] * Task.count
    end
    
    it "should preserve created_at dates when loading a basecamp dump" do
      data = File.open("#{Rails.root}/spec/fixtures/campdump.xml") { |f| Hash.from_xml f.read }
      TeamboxData.new.tap{|d| d.service = 'basecamp'; d.data = data }.unserialize({}, {:create_users => true, :create_organizations => true})
      
      Comment.all.each {|o| o.created_at.year.should == 2009}
      Project.all.each {|o| o.created_at.year.should == 2009}
      Task.all.each {|o| o.created_at.year.should == 2009}
      TaskList.all.each {|o| o.created_at.year.should == 2009}
      Conversation.all.each {|o| o.created_at.year.should == 2009}
    end
  end
  
  describe "serialize" do
    it "should serialize data" do
      make_the_teambox_dump
      encoded_data = ActiveSupport::JSON.encode TeamboxData.new.serialize(Organization.all, Project.all, User.all)
      account_dump = ActiveSupport::JSON.decode(encoded_data)['account']
      account_dump['projects'].length.should == 1
      project_dump = account_dump['projects'][0]
      project_dump['task_lists'].length.should == 1
      project_dump['task_lists'][0]['tasks'].length.should == 1
      project_dump['conversations'].length.should == 1
      
      project_dump['id'].should == @project.id
      project_dump['task_lists'][0]['id'].should == @task_list.id
      project_dump['task_lists'][0]['tasks'][0]['id'].should == @task.id
      project_dump['conversations'][0]['id'].should == @conversation.id
      project_dump['conversations'][0]['comments'][0]['id'].should == @conversation.comments.first.id
    end
  end
  
  describe "do_export" do
    it "should only serialize projects from organizations the user is an admin of" do
      make_the_teambox_dump
      
      user = Factory(:user)
      dump = TeamboxData.new.tap{|d|d.type_name='export';d.user=user}
      dump.project_ids = Project.all.map(&:id)
      dump.save
      
      encoded_data = File.open(dump.processed_data.path){|f|f.read}
      account_dump = ActiveSupport::JSON.decode(encoded_data)['account']
      account_dump['projects'].length.should == 0
    end
  end
  
  describe "do_import" do
    it "should import projects into the target organization" do
      make_and_dump_the_teambox_dump
      
      organization = Factory(:organization)
      user = Factory(:user)
      user_map = @user_list.inject({}){|a,key| a[key] = user.login; a}
      
      organization.add_member(user, Membership::ROLES[:admin])
      dump = TeamboxData.new.tap{|d|d.type_name='import';d.service='teambox';d.user=user; d.save}
      dump.data = @teambox_dump
      dump.target_organization = organization.permalink
      dump.user_map = user_map
      dump.status_name = :mapping
      
      dump.save.should == true
      dump.error?.should_not == true
      dump.status_name.should == :imported
      dump.processed_at.should_not == nil
      organization.reload.projects.length.should == 1
    end
    
    it "should still import projects into the target organization after a DJ save" do
      make_and_dump_the_teambox_dump
      
      organization = Factory(:organization)
      user = Factory(:user)
      user_map = @user_list.inject({}){|a,key| a[key] = user.login; a}
      
      organization.add_member(user, Membership::ROLES[:admin])
      dump = TeamboxData.new.tap{|d|d.type_name='import';d.service='teambox';d.user=user; d.save}
      dump.import_data = mock_uploader('dump.js', 'text/json', ActiveSupport::JSON.encode(@teambox_dump))
      dump.save
      dump.target_organization = organization.permalink
      dump.user_map = user_map
      dump.status_name = :pre_processing
      
      dump.save.should == true
      dump = TeamboxData.find_by_id(dump.id)
      
      dump.map_data.should_not == nil
      dump.error?.should_not == true
      dump.status_name.should == :pre_processing
      dump.data.should_not == nil
      dump.do_import
      
      dump.status_name.should == :imported
      organization.reload.projects.length.should == 1
    end
    
    it "should not allow unknown users to be mapped" do
      make_and_dump_the_teambox_dump
      
      organization = Factory(:organization)
      user = Factory(:user)
      unknown_user = Factory(:user)
      user_map = @user_list.inject({}){|a,key| a[key] = unknown_user.login; a}
      
      organization.add_member(user, Membership::ROLES[:admin])
      dump = TeamboxData.new.tap{|d|d.type_name='import';d.service='teambox';d.user=user;d.save}
      dump.data = @teambox_dump
      dump.target_organization = organization.permalink
      dump.user_map = user_map
      dump.status_name = :mapping
      
      dump.save.should == false
      dump.status_name.should == :mapping
      dump.processed_at.should == nil
      organization.projects.length.should == 0
      Activity.count.should == 0
    end
    
    it "should not alter existing memberships in the target organization" do
      make_and_dump_the_teambox_dump
      
      organization = Factory(:organization)
      user = Factory(:user)
      user_map = @user_list.inject({}){|a,key| a[key] = user.login; a}
      
      organization.add_member(user, Membership::ROLES[:admin])
      dump = TeamboxData.new.tap{|d|d.type_name='import';d.service='teambox';d.user=user; d.save}
      dump.data = @teambox_dump
      dump.target_organization = organization.permalink
      dump.user_map = user_map
      dump.status_name = :mapping
      
      @teambox_dump['account']['organizations'].each do |org|
        org['members'].each { |member| member['role'] = 20 }
      end
      
      roles = organization.memberships.map(&:role)
      member_ids = organization.memberships.map(&:user_id)
      
      dump.save.should == true
      dump.error?.should_not == true
      dump.status_name.should == :imported
      
      organization.memberships(true).map(&:role).should == roles
      organization.memberships(true).map(&:user_id).should == member_ids
    end
    
    it "should not import projects into an organization the user is not an admin of" do
      make_and_dump_the_teambox_dump
      
      Organization.destroy_all
      User.destroy_all
      Project.destroy_all
      
      organization = Factory(:organization)
      user = Factory(:user)
      user_map = @user_list.inject({}){|a,key| a[key] = user.login; a}
      
      dump = TeamboxData.new.tap{|d|d.type_name='import';d.service='teambox';d.user=user}
      dump.data = @teambox_dump
      dump.target_organization = organization.permalink
      dump.user_map = user_map
      dump.status_name = :mapping
      
      dump.save.should == false
      dump.status_name.should == :mapping
      dump.processed_at.should == nil
      organization.projects.length.should == 0
      Activity.count.should == 0
    end
  end
  
  describe "import_from_file" do
    it "should import data from a file" do
      TeamboxData.import_from_file("#{Rails.root}/spec/fixtures/teamboxdump.json", {}, {:create_users => true, :create_organizations => true})
      
      Organization.count.should == 1
      Project.count.should == 1
      User.count.should == 4
    end
  end
  
  describe "export_to_file" do
    it "should export data to a file" do
      make_the_teambox_dump
      TeamboxData.export_to_file(Project.all, User.all, Organization.all, "#{Rails.root}/tmp/test-export.json")
    end
  end
  
  describe "to_api_hash" do
    it "should generate an api representation of this object" do
      make_the_teambox_dump
      
      user = Factory(:user)
      dump = TeamboxData.new.tap{|d|d.type_name='export';d.user=user}
      dump.project_ids = Project.all.map(&:id)
      dump.save
      
      dump.to_api_hash.should_not == nil
    end
  end
end
