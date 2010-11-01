require 'spec_helper'

describe HoursController do
  
  before do
    @user = Factory(:confirmed_user)
    @project = Factory(:project)
    @project.add_user @user
    
    Factory(:comment, :project => @project, :user => @user, :hours => 4.2)
    Factory(:comment, :project => @project, :user => @user, :hours => 1.2)
    Factory(:comment, :project => @project, :hours => 2.0)
    Factory(:comment, :project => @project, :hours => 2.0).update_attribute(:created_at, Time.now-2.months)
  end
  
  it "shows the hours for the current month in a project in CSV format" do
    login_as @user
    
    get :index, :month => Time.now.month, :year => Time.now.year, :format => 'csv'
    response.should be_success
    
    data = decode_test_csv(response.body)
    data.length.should == 4
  end
  
  it "shows the hours for a specific time period in a project in CSV format" do
    login_as @user
    
    last_time = Comment.last.created_at
    current_time = Time.now
    
    get :by_period, :start_year => last_time.year,
                    :start_month => last_time.month,
                    :start_day => last_time.day, 
                    :end_year => current_time.year, 
                    :end_month => current_time.month,
                    :end_day => current_time.day,
                    :format => 'csv'
    response.should be_success
    
    data = decode_test_csv(response.body)
    data.length.should == 5
  end
end