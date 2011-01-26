require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  it { should belong_to(:user) }
  it { should belong_to(:project) }
  it { should have_many(:notes) }
  it { should have_many(:dividers) }
  it { should have_many(:uploads) }

  describe "factories" do
    it "should generate a valid page" do
      page = Factory.create(:page)
      page.valid?.should be_true
    end
  end
  
  describe "destruction" do
    before do 
      @page = Factory.create(:page)
      @note = @page.build_note({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = @page.user
        n.save
      end
      @divider = @page.build_divider({:name => 'Office Ettiquete'}).tap do |n|
        n.updated_by = @page.user
        n.save
      end
    end
    
    it "should destroy all page slots and objects" do
      @page.destroy
      
      Page.count.should == 0
      PageSlot.count.should == 0
      Divider.count.should == 0
      Note.count.should == 0
    end
    
    it "should destroy all page slots and objects when the project is destroyed" do
      @page.project.destroy
      
      Page.count.should == 0
      Divider.count.should == 0
      Note.count.should == 0
      PageSlot.count.should == 0
    end
  end


  describe "format" do
    before do
      @page=Factory.create(:page)
      @note=@page.build_note({:name=>'A note',:body=> <<-STR
<table border="1">
<tr>
<th></th>
<th align="center"> heading 1 </th>
<th>heading 2</th>
<th>heading 3</th>
<tr>
</table>
      STR
      }).tap do |n|
        n.updated_by = @page.user
        n.save
      end
    end
    it "should display the correct format" do
      @note.body_html.should include('<tr>')
      @note.body_html.should include('<table>')
      @note.body_html.should include('<th>')
    end
  end

end
