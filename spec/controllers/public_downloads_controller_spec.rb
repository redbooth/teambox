require File.dirname(__FILE__) + '/../spec_helper'

describe PublicDownloadsController do
  render_views
  
  before do
    make_a_typical_project
    @upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
    @upload.user = @user
    @upload.save!
  end
  
  route_matches("/d/aaBBccdd33ffGG44",
    :get, 
    :controller => "public_downloads",
    :action => "download", 
    :token => "aaBBccdd33ffGG44")

  route_matches("/send/aaBBccdd33ffGG44",
    :get,
    :controller => "public_downloads",
    :action => "download_send",
    :token => "aaBBccdd33ffGG44")
  
  describe "GET #download" do
    it "should display downloads landing page for correct token" do
      get :download, :token => @upload.token
      response.code.should eq("200")
      response.should render_template("public_downloads/download")
    end
    
    it "should show file not found page for invalid token" do
      get :download, :token => 'th1SiS1nVaL1Dt0k33n'
      response.code.should eq("404")
      response.should render_template("public_downloads/not_found")
    end
  end

  describe "GET #send" do
    it "should send a file with correct headers to the browser" do
      
      get :download_send, :token => @upload.token

      response.code.should eq("200")
      response.body.should eq("alert('what?!')")
      response.header["Content-Disposition"].should match(/filename=\"#{@upload.asset_file_name}\"/)
      response.header["Content-Type"].should eq(@upload.asset_content_type)
    end

    it "should return not found for invalid token" do

      get :download_send, :token => 'th1SiS1nVaL1Dt0k33n'

      response.code.should eq("404")
    end

  end

end