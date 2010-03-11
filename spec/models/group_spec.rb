require File.dirname(__FILE__) + '/../spec_helper'

describe Group do

  it { should belong_to(:user) }
  it { should have_and_belong_to_many(:users) }
  it { should have_many(:projects) }
  it { should have_many(:invitations) }
  
  it { should validate_presence_of(:user) }
  it { should validate_length_of(:name, :minimum => 3) }
  it { should validate_length_of(:permalink, :minimum => 5) }

  describe "creating a group" do
    before do
      @owner = Factory.create(:user)
      @group = Factory.create(:group, :user_id => @owner.id)
    end

    it "should belong to its owner" do
      @group.user.should == @owner
      @group.owner?(@owner).should be_true
      @group.users.should include(@owner)
      @owner.reload
      @owner.groups.should include(@group)
    end
  end

  describe "inviting users" do
    before do
      @owner = Factory.create(:user)
      @group = Factory.create(:group, :user_id => @owner.id)
      @user = Factory.create(:user)
    end

    it "should add users only once" do
      added = @group.add_user(@user)
      added.should == true
      @group.should have(2).users
      lambda { @group.add_user(@user) }.should_not change(@group, :users)
    end
  end

  describe "removing users" do
    before do
      @owner = Factory.create(:user)
      @group = Factory.create(:group, :user_id => @owner.id)
      @user = Factory.create(:user)
      @group.add_user(@user)
    end

    it "should remove users" do
      @group.should have(2).users
      @group.reload.remove_user(@user)
      @group.should have(1).users
      @group.users.should_not include(@user)
      @user.reload.groups.should_not include(@group)
    end
  end

  describe "deleting groups" do
    before do
      @owner = Factory.create(:user)
      @group = Factory.create(:group, :user_id => @owner.id)
      @invitation = Invitation.new(:user_or_email => 'frodo@localhost.com')
      @invitation.group = @group
      @invitation.user = @owner
      @invitation.save!
    end

    it "should have some elements" do
      Invitation.count.should == 1
    end

    it "destroy all its comments, conversations, task lists, pages, uploads and people" do
      @group.destroy
      Invitation.count.should == 0
    end

  end
end