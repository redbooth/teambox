class ActivityRenderer < TemplateRenderer

  def self.target_url(activity, path = true)
    case activity.target.class.name
    when *%w(Conversation TaskList Task Page Upload)
      url_for([ activity.project, activity.target ], :only_path => path)
    when *%w(Comment)
      url_for([ activity.project, activity.comment_target ], :only_path => path)
    when *%w(Note Divider)
      url_for(activity.project, :only_path => path)
    else
      url_for(activity.target, :only_path => path)
    end
  end


  def self.render_activity(activity)
    if %w(create edit).include? activity.action
      case activity.target.class.name
      when "Comment"
        render_template(:partial => 'comments/comment', :locals => {:comment => activity.target})
      when *%w(Task Conversation)
        render_template(:partial =>'activities/thread', :locals => {:activity=> activity})
      else
        render_template(:partial => "activities/#{activity.action_type}", :locals => {
          :activity => activity,
          activity.target_type.underscore.to_sym => activity.target
        })
      end
    else
      nil
    end
  end
end

