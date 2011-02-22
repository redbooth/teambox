require 'spec_helper'

# Warning these tests are increadibly brittle but they did allow the library to be created succesfully.
describe Nomadesk do
  it "should raise an error if created without a username and password" do
    lambda { Nomadesk.new() }.should raise_error(ArgumentError)
  end
  
  it "shouldn't raise an error if created with a username and password" do
    lambda { Nomadesk.new(:user => 'test', :pass => 'test') }.should_not raise_error
  end
  
  it "should raise an error when not passed all required params to #create_account" do
    lambda { Nomadesk.create_account(:email => 'justexample@example.com') }.should raise_error(ArgumentError)
  end
  
  it "should allow a new account to be created" do
    email = 'newnomadesk_test@teambox.com'
    host = 'teambox.nomadeskdemo.com'
    
    account = Nomadesk.create_account(
      :email => email,
      :password => 'password',
      :first_name => 'steve',
      :last_name => 'test',
      :phone => '00000000000',
      :skip_confirm => 'true',
      :host => host
    )
    account.should be_an_instance_of(Nomadesk::Token)
    account.key.should_not be_nil
    
    Nomadesk.suspend_account(email, host)
    Nomadesk.destroy_account(email, host)
  end
  
  it "should classify keys when sent the private method #classify_keys" do
    hash = Nomadesk.send(:format_keys, {"example" => 'value', :classify_this => 'value', :and_another_one => 'test'})
    hash.keys.should =~ ['Example', 'ClassifyThis', 'AndAnotherOne']
  end
  
  it "should create a new fileserver when a new account is created and a fileserver label is passed"
  
  describe "with valid authentication params" do
    before(:each) do
      @nomadesk = Nomadesk.new(:host => "teambox.nomadeskdemo.com", :user => "nomadesk@teambox.com", :pass => "password")
      @existing_bucket_name = "nmsa000140"
      @existing_bucket_label = "for-specs"
      
      # @nomadesk = Nomadesk.new(:user => "nomadesk@teambox.com", :pass => "papapa")
      # @existing_bucket_name = "nmsa120663"
      # @existing_bucket_label = "Teambox-fs2"
    end
    
    it "should allow a password to be changed" do
      @nomadesk.change_password('password', 'password1')
      
      lambda {
        Nomadesk.new(:host => @nomadesk.host, :user => 'nomadesk@teambox.com', :pass => 'password1')
      }.should_not raise_error
      
      @nomadesk.change_password('password1', 'password')
    end
    
    it "should allow an email address to be changed" do
      @nomadesk.change_email('teambox2@dynedge.co.uk', true)
      
      lambda {
        Nomadesk.new(:host => @nomadesk.host, :user => 'nomadesk2@teambox.com', :pass => 'password')
      }.should_not raise_error
      
      @nomadesk.change_email('nomadesk@teambox.com', true)
    end
    
    it "should present an access token when sent #token" do
      @nomadesk.token.should be_an_instance_of Nomadesk::Token
      @nomadesk.token.key.should_not be_blank
      @nomadesk.token.key.length.should == 26
    end
    
    it "should present a list of buckets when sent #buckets" do
      buckets = @nomadesk.buckets
      
      buckets.should be_instance_of(Array)
      
      buckets.first.should be_instance_of(Nomadesk::Bucket)
      buckets.first.name.should == @existing_bucket_name
      buckets.first.label.should == @existing_bucket_label
    end
  
    it "should present a list of files when sent #list with a bucket" do
      bucket = @nomadesk.buckets.first
      
      items = @nomadesk.list(bucket)
      
      items.should be_instance_of(Array)
      items.first.should be_instance_of(Nomadesk::Item)
      items.first.name.should == "this is a folder"
      items.first.path.should == "/"
      items.first.is_folder?.should be_true
      items.first.modified.should == DateTime.new(2011, 03, 16, 10, 59, 45)
      
      items.second.is_folder?.should be_false
    end
    
    it "should find a bucket given it's name when sent #get_bucket with the name" do
      bucket = @nomadesk.get_bucket(@existing_bucket_name)
      bucket.name.should == @existing_bucket_name
      bucket.label.should == @existing_bucket_label
    end
    
    # This is a private method in the API
    # it "should allow searching of buckets when send #find_bucket with the label" do
    #   bucket = @nomadesk.find_bucket('Teambox-fs2')
    #   bucket.should == "nmsa120663"
    # end
    
    it "should present a download link when sent #download link with a bucket and a path" do
      bucket = @nomadesk.buckets.first
      item = @nomadesk.list(bucket).second # This is a file not dir
      
      expected = "#{bucket.api_url}?FileserverName=#{bucket.name}&Token=#{@nomadesk.token.key}&Task=FileDownload&Path=#{item.path}#{ERB::Util.url_encode(item.name)}"
      @nomadesk.download_url(bucket, item.full_path).should == expected
    end
    
    it "should allow direct access to a download link from the item" do
      bucket = @nomadesk.buckets.first
      item = @nomadesk.list(bucket).second # This is a file not dir
      item.download_url.should_not be_blank
    end
    
    it "should allow us to create a new fileserver and then delete it" do
      bucket = nil
      label = "test-#{rand(1000)}"
      
      bucket = @nomadesk.create_bucket(label)
      bucket.label.should == label
      bucket.name.should_not be_nil
      #@nomadesk.buckets.map{|b| bucket.label }.should include(label)
      
      # we cannot rely on the bucket being removed at this point so just assume that if the call went ok it's fine
      @nomadesk.delete_bucket(bucket).should be_true
      #@nomadesk.buckets.map{|b| bucket.label }.should_not include(label)
    end
    
    it "should create a new folder when sent #create_folder" do
      bucket = @nomadesk.buckets.first
      folder = nil
      
      length = bucket.list.length
      folder = @nomadesk.create_folder(bucket, 'myfolder')
        
      folder.should be_instance_of(Nomadesk::Item)
      folder.name.should == "myfolder"
      folder.is_folder?.should be_true
      bucket.list.length.should == length + 1
      
      folder.delete
      bucket.list.length.should == length
    end
    
    it "should allow a user to be invited to a folder" do
      email = 'newnomadesk_test2@teambox.com'
      bucket = @nomadesk.buckets.first
      
      invite_user = @nomadesk.invite_email(
        bucket.name,
        email,
        true,
        :read_write
      ).should be_true
      
      @nomadesk.remove_user(bucket.name, email).should be_true
    end
    
    # TODO: Add tests for all the methods that generate urls etc. At the moment these are basically just functional tests
  end
end
