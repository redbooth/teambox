require File.dirname(__FILE__) + '/../spec_helper'

describe "permalink" do
  [:organization, :project].each do |model| # model with permalink
    it "should check weird permalinks for #{model}" do
      %w(with.dots with%percent with$dolars with&ampersands with^carets).each do |permalink|
        Factory.create(model, :permalink => permalink).permalink.should == permalink.gsub(/[\.\%\$\&\^]/, '')
      end
    end

    it "should add class name to numerical permalink for #{model}" do
      %w(1020 1233.2).each do |permalink|
        obj = Factory.create(model, :permalink => permalink)
        obj.permalink.should == "#{obj.class.to_s.downcase}-#{permalink.gsub('.','')}"
      end
    end

    it "should add integer to #{model} permalink if its already taken" do
      first_obj = Factory.create(model, :permalink => "permalink")
      duplicate = Factory.create(model, :permalink => "permalink")
      duplicate.permalink.should_not == first_obj.permalink
    end

    it "should replace non-ascii chars with their ascii counterparts" do
      obj = Factory.create(model, :permalink => "òéàüñ ìí")
      obj.permalink.should == "oeaun-ii"
    end

    it "should generate a unique permalink to #{model} if none is given" do
      first_obj = Factory.create(model, :name => 'Teambox')
      first_obj.permalink.should_not be_nil
      duplicate = Factory.create(model, :name => 'Teambox!!!')
      duplicate.permalink.should_not == first_obj.permalink
    end
  end
end
