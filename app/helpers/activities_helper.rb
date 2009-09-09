module ActivitiesHelper
  def list_activities(activities)
    render :partial => 'activities/activity', :collection => activities
  end
  
  def show_activity(activity)
    render(:partial => "activities/#{activity.target.class.name.downcase}_#{activity.action}",
      :locals => { :activity => activity })
  end
end