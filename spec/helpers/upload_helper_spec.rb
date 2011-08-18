require 'spec_helper'

describe UploadsHelper do
  describe "file_icon_path" do
    before { @upload = Factory(:upload) }
        
    it "returns path for default size" do
      helper.file_icon_path(@upload).should == "/images/file_icons/48px/png.png"
    end
    
    it "returns path for given size" do
      helper.file_icon_path(@upload, '20px').should == "/images/file_icons/20px/png.png"
    end
  end
end
