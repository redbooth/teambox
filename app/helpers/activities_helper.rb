module ActivitiesHelper
  def list_activities(activities)
    render :partial => 'activities/activity', :collection => activities
  end
  
  def show_activity(activity)
    target_class = activity.target.class.name.downcase
    if target_class == 'nilclass'
      render(:partial => 'activities/deleted')
    else
      render(:partial => "activities/#{activity.target.class.name.downcase}_#{activity.action}",
        :locals => { :activity => activity })
    end
  end
end