require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do

  it { should have_many(:projects) }
  it { should have_many(:users) }
  it { should have_many(:task_list_templates) }

  #it { should validate_presence_of(:permalink) }
  it { should validate_length_of(:name, :minimum => 1) }
  it { should validate_length_of(:permalink, :minimum => 4) }

  describe "permalink" do
    it "should check weird permalinks" do
      %w(www help mail).each do |sym|
        Factory.build(:organization, :permalink => sym).should_not be_valid
      end

      %w(with_underscores with-dashes fuckingnormaldomain).each do |sym|
        Factory.build(:organization, :permalink => sym).should be_valid
      end
    end
  end

  describe "validating length of name and permalink" do
    it "should fail on create if the name is shorter than 1 chars" do
      organization = Factory.build(:organization, :name => "")
      organization.should be_invalid
      organization.should have(1).error_on(:name)
    end

    it "should allow existent organizations to have a name at least 1 chars if they don't change it" do
      organization = Factory.build(:organization, :name => "a", :permalink => "abcdefg")
      organization.save(:validate => false)
      organization.should be_valid
    end
    
    it "should not allow permalinks with less than 4 chars" do
      organization = Factory.build(:organization, :name => "a", :permalink => "abcdefg")
      organization.save(:validate => false)
      organization.should be_valid
      organization.permalink = "2"
      organization.save
      (organization.reload.permalink.length >= 4).should == true
    end

    it "should fail if the name is updated and shorter than 1 chars" do
      organization = Factory.create(:organization, :name => "abc123")
      organization.name = ""
      organization.should be_invalid
    end

  end

  describe "domain" do
    it "should allow multiple organizations with nil domain" do
      Factory(:organization, :domain => nil)
      Factory.build(:organization, :domain => nil).should be_valid
    end
    it "should allow multiple organizations with blank domain" do
      Factory(:organization, :domain => '')
      Factory.build(:organization, :domain => '').should be_valid
    end
    it "shouldn't take a deleted organization's domain as busy" do
      o = Factory(:organization, :domain => 'mofo.teambox.dev')
      o.destroy
      Factory.build(:organization, :domain => 'mofo.teambox.dev').should be_valid
    end
  end

  it "should not be destroyed if it has any projects" do
    organization = Factory(:organization)
    Factory(:project, :organization => organization)
    organization.reload.projects.count.should == 1
    lambda { organization.destroy }.should_not change(Organization, :count)
  end

  describe "projects" do
    before do
      @organization = Factory(:organization)
    end
    it "should add a project" do
      project = Factory(:project, :organization => @organization)
      project.valid?.should be_true
      project.organization.should == @organization
    end
    it "should transfer projects" do
      project = Factory(:project, :organization => @organization)
      new_organization = Factory(:organization)
      project.organization = new_organization
      project.save.should be_true
      project.organization.should == new_organization
      @organization.projects.should == []
      new_organization.projects.should == [project]
    end
  end

  describe "users" do
    before do
      @organization = Factory(:organization)
    end
    it "should add admins" do
      user = Factory(:user)
      @organization.add_member(user, :admin)
      @organization.users.should == [user]
      @organization.admins.should == [user]
      @organization.participants.should == []
      @organization.external_users.should == []
      @organization.users_in_projects.should == []
      @organization.is_admin?(user).should be_true
      @organization.is_participant?(user).should be_false
    end
    it "should add participants" do
      user = Factory(:user)
      @organization.add_member(user, :participant)
      @organization.users.should == [user]
      @organization.admins.should == []
      @organization.participants.should == [user]
      @organization.external_users.should == []
      @organization.users_in_projects.should == []
      @organization.is_admin?(user).should be_false
      @organization.is_participant?(user).should be_true
    end
    it "should list people in projects as external users" do
      project = Factory(:project, :organization => @organization)
      @organization.users(true).should == [project.user]
      @organization.admins.should == [project.user]
      @organization.participants.should == []
      @organization.external_users.should == []
      @organization.users_in_projects.should == [project.user]
      @organization.is_admin?(project.user).should be_true
      @organization.is_participant?(project.user).should be_false
    end
    it "should list people in projects and the org as users" do
      admin = Factory(:user)
      @organization.add_member(admin, :admin)
      project = Factory(:project, :organization => @organization)
      @organization.add_member(project.user, :participant)
      @organization.reload.user_ids.sort.should == [admin.id, project.user_id].sort
      @organization.admins.should == [admin]
      @organization.participants.should == [project.user]
      @organization.external_users.should == []
      @organization.users_in_projects.should == [project.user]
      @organization.is_admin?(project.user).should be_false
      @organization.is_participant?(project.user).should be_true
    end
    it "should not add members with invalid roles" do
      user = Factory(:user)
      @organization.add_member(user, 0).should be_false
      @organization.add_member(user, 40).should be_false
      @organization.add_member(-4).should be_false
    end
    it "should not add members twice" do
      user = Factory(:user)
      @organization.add_member(user, 20).should be_true
      @organization.memberships.last.user_id.should == user.id
      @organization.memberships.length.should == 1
      @organization.add_member(user, 20)
      @organization.memberships.length.should == 1
    end
    it "should upgrade participants" do
      user = Factory(:user)
      @organization.add_member(user, 10).should be_true
      @organization.add_member(user, 30).should be_true
      @organization.memberships.last.user_id.should == user.id
      @organization.memberships.last.role.should == 30
      @organization.memberships.length.should == 1
    end
    it "should not destroy or downgrade the last admin" do
      user = Factory(:user)
      @organization.add_member(user, 30).should be_true
      member = @organization.memberships.last
      member.role = 20
      member.save.should be_false
    end
    it "should not destroy or downgrade the last admin" do
      user = Factory(:user)
      @organization.add_member(user, 30).should be_true
      member = @organization.memberships.last
      member.destroy.should be_false
    end
    it "should destroy organization even if there is only one admin" do
      user = Factory(:user)
      @organization.add_member(user, 30).should be_true
      @organization.admins.count.should == 1
      @organization.destroy.should be_true
    end
  end

  describe "single organization mode" do
    before { Teambox.config.community = true }
    after  { Teambox.config.community = false }
    it "should allow creating one organization" do
      Organization.destroy_all
      Factory(:organization).valid?.should be_true
      Factory.build(:organization).valid?.should be_false
    end
  end

  describe "factories" do
    it "should generate a valid organization" do
      organization = Factory(:organization)
      organization.valid?.should be_true
      organization.users.should be_empty
      organization.projects.should be_empty
    end
  end
  
  describe "logo" do
    before do
      Teambox.config.amazon_s3 = false
      @organization = Factory.create(:organization, :logo => upload_file("#{Rails.root}/spec/fixtures/tb-space.jpg", 'image/jpeg'))
    end
    
    it "deletes the logo when delete_logo is set" do
      @organization.update_attributes :delete_logo => '1'
      @organization.logo_file_name.should == nil
    end
    
    it "does not delete the logo when delete_logo is not set" do
      @organization.update_attributes :delete_logo => '0'
      @organization.logo_file_name.should_not == nil
    end
  end

end
