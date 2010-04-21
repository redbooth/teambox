require File.dirname(__FILE__) + '/../spec_helper'

describe JennyHelper do
  before do
    @owner = Factory.create(:user)
    @project = Factory.create(:project, :user_id => @owner.id)
    @task_list = Factory.create(:task_list, :project_id => @project.id)
  end
  
  describe 'js_id' do
    it 'should assign an element if first arg is a symbol or a string'
    it 'should remove the first element from args if its a symbol or a string'
    it 'should assign nil to element if first element is not a symbol a string'
    it 'should raise an error if all args are not models or first followed by a string/symbol and then all models'
    it 'should get the singular name of a model'
    it 'js_id(:edit_header,@project,@tasklist) => project_21_task_list_12_edit_header' do
      helper.js_id(:edit_header,@project,@task_list).should == "project_#{@project.id}_task_list_#{@task_list.id}_edit_header"
    end
    it 'js_id(:new_header,@project,TaskList.new) => project_21_task_list_new_header' do
      helper.js_id(:new_header,@project,TaskList.new).should == "project_#{@project.id}_task_list_new_header"
    end
    # NOTE: this does not work... should it work? [need to check existing code]
    #it 'js_id(@project,TaskList.new) => project_21_task_list' do
    #  helper.js_id(@project,TaskList.new).should == "project_#{@project.id}_task_list"
    #end
    it 'js_id(nil,@project,TaskList.new) => project_21_task_list' do
      helper.js_id(nil,@project,TaskList.new).should == "project_#{@project.id}_task_list"
    end
  end
  
  describe 'app_link' do
    it 'should assign action to new for new records'
    it 'should assign action to edit for existing records'
    it 'should get the singular name of a model'
    it 'should get the plural name of a model'
    it 'should call show action'
    it 'should assign the class name'
    it 'should assign the id'
  end
  
  describe 'app_toggle' do
  end
end