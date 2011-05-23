require File.dirname(__FILE__) + '/../spec_helper'

describe TeamboxDatasController do
  route_matches("/datas/22/download", 
    :get, 
    :controller => "teambox_datas", 
    :action => "download", 
    :id => "22")
  
  describe "#download" do
    it "should send data" do
      make_the_teambox_dump
      
      dump = TeamboxData.new.tap{|d|d.type_name='export';d.user=@project.user}
      dump.project_ids = Project.all.map(&:id)
      dump.save
      
      login_as @project.user
      get :download, :id => dump.id
      
      response.body.match(/account/).should_not == nil
    end
  end
end  
