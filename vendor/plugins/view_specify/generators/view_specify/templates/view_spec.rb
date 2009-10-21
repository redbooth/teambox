require File.dirname(__FILE__) + "<%= root_directory %>/spec_helper"

describe '<%= view_template_path_stem %>' do
  it 'should render' do
    <%= mocks_and_stubs %>
        
    render '<%= view_template_path_stem %>'
  end
end
