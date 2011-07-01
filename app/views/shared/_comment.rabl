attributes :id,
           :body,
           :body_html,
           :user_id,
           :project_id,
           :target_id,
           :target_type,
           :hours

code :type do |c|
  c.class.to_s
end

if @activity.target.target_type == 'Task'
  attributes :assigned_id,
             :previous_assigned_id,
             :previous_status,
             :status,
             :due_on,
             :previous_due_on
end

child :uploads, :if => lambda {|c| c.uploads.any?} do
  attributes :id,
             :page_id,
             :description,
             :user_id,
             :comment_id,
             :is_private

  attributes :asset_file_name => :filename,
             :asset_file_size => :bytes,
             :asset_content_type => :mime_type,
             :url => :download

  code :type do |c|
    c.class.to_s
  end

  %w(created_at updated_at).each do |attr|
    code(attr.to_sym) do |u|
      u.send(attr.to_sym).to_s(:api_time)
    end
  end

  code :slot_id do |u|
    u.page_slot ? u.page_slot.id : nil
  end
end

code :assigned do |a|
  partial('shared/_assigned', :object => a.assigned)
end

code :type do |thread|
  thread.class.to_s
end

%w(created_at updated_at).each do |attr|
  code(attr.to_sym) do |thread|
    thread.send(attr.to_sym).to_s(:api_time)
  end
end

code :project do |a|
  partial('shared/_project_small', :object => a.project)
end

code :user do |a|
  partial('shared/_user_small', :object => a.user)
end

