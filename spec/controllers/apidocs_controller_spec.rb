require File.dirname(__FILE__) + '/../spec_helper'

describe ApidocsController do

  it 'does not create example objects if there are no organizations on first access' do
    
    Project.count.should == 0
    User.count.should == 0
    Organization.count.should == 0
    
    get :index
    
    Project.count.should == 0
    User.count.should.should == 1
    Organization.count.should == 0
  end
  
  it 'creates example objects if there are organizations on first access' do
    Factory.create(:organization)
    Project.count.should == 0
    User.count.should == 0
    Person.count.should == 0
    Organization.count.should == 1
    Membership.count.should == 0
    
    get :index
    
    User.count.should.should == 1
    Organization.count.should == 2
    Membership.count.should == 1
    Project.count.should == 1
    Person.count.should == 1
    
    get :index
    
    User.count.should.should == 1
    Organization.count.should == 2
    Membership.count.should == 1
    Project.count.should == 1
    Person.count.should == 1
  end
  
  it 'should show documentation for all documented models' do
    ApidocsController::DOCUMENTED_MODELS.each do |model|
      get :model, :model => model
      response.should be_success
    end
  end
    
end  
