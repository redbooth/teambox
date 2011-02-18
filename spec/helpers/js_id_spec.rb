require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  before do
    @owner = Factory.create(:user)
    @project = Factory.create(:project, :user_id => @owner.id)
    @task_list = Factory.create(:task_list, :project_id => @project.id)
  end

  describe 'js_id' do
    it 'js_id(:edit_header,@project,@tasklist) => project_21_task_list_12_edit_header' do
      helper.js_id(:edit_header,@project,@task_list).should == "project_#{@project.id}_task_list_#{@task_list.id}_edit_header"
    end
    it 'js_id(:new_header,@project,TaskList.new) => project_21_task_list_new_header' do
      helper.js_id(:new_header,@project,TaskList.new).should == "project_#{@project.id}_task_list_new_header"
    end
    it 'js_id(nil,@project,TaskList.new) => project_21_task_list' do
      helper.js_id(nil,@project,TaskList.new).should == "project_#{@project.id}_task_list"
    end
  end

end
