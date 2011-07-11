require 'spec_helper'

describe FoldersHelper do

  before do
    @current_project = stub_model(Project, :name => "Pulp Fiction", :to_param => "pulp-fiction")
    parent_folder = stub_model(Folder, :name => "Vincent Vega", :id => 22)
    @current_folder = stub_model(Folder, :name => "Mia Vallace", :parent_folder => parent_folder, :id => 23)
  end

  describe "folder_breadcrumbs" do
    it "should return proper breadcrumb" do
      helper.folder_breadcrumbs.should match /<a href=\"\/projects\/pulp-fiction\/uploads\">Pulp Fiction<\/a> » <a href=\"\/projects\/pulp-fiction\/uploads\/folders\/22\">Vincent Vega<\/a> » Mia Vallace/
    end
  end
  
end