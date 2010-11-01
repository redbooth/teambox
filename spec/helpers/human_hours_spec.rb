require 'spec_helper'

describe ApplicationHelper, "#human_hours" do

  it "ignores zero" do
    result(0).should be_nil
  end

  it "gets hours" do
    result(5).should == "5h"
  end

  it "outs hours and minutes" do
    result(1 + 13/60.0).should == "1h 13m"
  end

  it "handles 1/3" do
    result(20/60.0).should == "0h 20m"
  end

  it "removes incomplete minutes" do
    result(1.001).should == "1h"
  end

  it "rounds up complete minutes" do
    result(1.995).should == "2h"
  end
  
  it "rounds up correctly" do
    result(159.999840000001).should == "160h"
  end
  
  it "rounds down zero" do
    result(0.001).should be_nil
  end
  
  def result(hours)
    helper.human_hours(hours)
  end

end