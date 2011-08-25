class WatchersController < ApplicationController
  skip_before_filter :load_project

  def index
    @watch_list_by_project = current_user.watchers.includes(:watchable).reject { |t|
	  t.project.nil? }.group_by { |t|
	  t.project.name
    }
  end

  def unwatch
    @watch = current_user.watchers.find_by_id params[:watch_id]
    @watch.destroy
    head :ok
  end
end.nil?