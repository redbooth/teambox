require 'gantt_chart'

module BannerSystem
  protected
    BANNER_SETTINGS = { :gantt => 0, :calendar => 1 }

    def current_banner?(setting)
      current_banner == BANNER_SETTINGS[setting]
    end
        
    def current_banner
      @current_banner ||= BANNER_SETTINGS[:gantt]
    end
    
    def current_banner=(setting)    
      session[:banner_setting] = BANNER_SETTINGS[setting]
      @current_banner = session[:banner_setting]
    end

    def load_banner
      if @current_project
        @chart_task_lists = []
        (@task_lists || @current_project.task_lists).each do |task_list|
          @chart_task_lists << GanttChart::Event.new(task_list.start_on, task_list.finish_on, task_list.name) unless task_list.start_on == task_list.finish_on
        end
        @chart = GanttChart::Base.new(@chart_task_lists)
        @events = split_events_by_date(Task.upcoming_for_project(@current_project.id))
      end
    end    

    def self.included(base)
      base.send :helper_method, :current_banner, :current_banner? if base.respond_to? :helper_method
    end
end  