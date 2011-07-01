class ActivityRenderer < TemplateRenderer
  def self.render_activity(activity, options={})
    render_template(:rabl, :partial =>'activities/activity', :locals => {:object=> false}, :rabl_assigns => {:activity => activity}.merge(options[:rabl_assigns]))
  end
end

