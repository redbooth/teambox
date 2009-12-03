require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  describe 'js_id' do
    it 'should assign an element if first arg is a symbol or a string'
    it 'should remove the first element from args if its a symbol or a string'
    it 'should assign nil to element if first element is not a symbol a string'
    it 'should raise an error if all args are not models or first followed by a string/symbol and then all models'
    it 'should get the singular name of a model'
    it 'js_id(:edit_header,@project,@tasklist) => project_21_task_list_12_edit_header'
    it 'js_id(:new_header,@project,Task.new) => project_21_task_list_new_header'
    it 'js_id(@project,Task.new) => project_21_task_list'
    it 'js_id(nil,@project,Task.new) => project_21_task_list'
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