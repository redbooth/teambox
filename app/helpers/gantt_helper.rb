# Builds a GANTT Chart from the given array of task_lists
# It'll need some CSS to display well, for example:
#
# .gantt { margin: 20px; }
#   .row { position: relative; display: block; margin-bottom: 2px; border: 1px solid #aaa; background: #aaa; width: 600px; height: 22px; }
#   .task_list { position: absolute; border: 1px solid #000; background: #5f5; height: 20px; white-space: nowrap; overflow: hidden; cursor: move; }

module GanttHelper
end

module GanttChart
  class Event
    attr_accessor :start, :final, :description, :link, :classes

    def initialize(start, final, description = nil, link = nil)
      @start = set_destination(start)
      @final = set_destination(final)
      @description = ERB::Util.h(description) || [@start,@final].join('-')
      @link = link
    end

    # Checks if two events overlap in time
    def overlaps?(task_list)
      ((task_list.start < final && final <= task_list.final) ||
        (start < task_list.final && task_list.final <= final))
    end

    def length
      final - start
    end

    def to_s
      @description
    end

    def set_destination(position)
      case position
        when Date
          (position - Time.current.to_date).to_i + 1
        when Fixnum
          position
        when NilClass
          nil
        else
          raise "Invalid date"
      end
    end 

  end

  class Base
    attr_accessor :task_lists, :rows

    def initialize(task_lists=nil)
      @task_lists = task_lists
      @offset = 10
    end

    def ruler_to_html(days,day_width)
      html = ''
      (0..days).each do |i|
        date = Time.current + i.day
        day_width_max = (i * day_width) + @offset
        five_spaces = day_width_max - (date.day > 9 ? 5 : 1)
        ten_spaces  = day_width_max - (date.day == 1 ? 10 : 0)

        major = [0,6].include?(date.wday) ? 'major' : ''
        date_day = date.day == 1 ? Date::ABBR_MONTHNAMES[date.month] : date.day

        html << "<div class='date #{major}' style='left: #{five_spaces}px;'>#{date_day}</div>"
        html << "<div class='mark' style='left: #{ten_spaces}px;'></div>"
      end
      "<div class='ruler'>#{html}</div>".html_safe
    end

    def to_html(day_width=30, margin=50, expanded=true)
      @expanded = expanded
      
      return if !@rows or @rows.empty?
      html = ruler_to_html(@final-@start,day_width)
      html << list_rows(@start,@final,day_width)
      html.html_safe
    end

    def process(start=1,final=10)
      @start = start
      @final = final
      @rows = []

      @task_lists.sort! do |a,b|
        if !a.start; -1
        elsif !b.start; 1
        else a.start <=> b.start; end
      end
    
      @task_lists.each do |task_list|
        # Clip the task_list to the given time window
        next if !task_list.start && !task_list.final # undefinated start and end
        task_list.start = start if task_list.start && task_list.start < start # past start date
        task_list.final = final if task_list.final && task_list.final > final # future final date
        if !task_list.start # undefined start date
          task_list.start = start-1
          task_list.classes = "undefined_start"
        end
        if !task_list.final # undefined final date
          task_list.final = final+1
          task_list.classes = "undefined_end"
        end
        
        next if task_list.start > final # not visible (future)
        next if task_list.final < start # not visible (past)

        add_to_rows(task_list)
      end
      @rows.nil? || @rows.empty?
    end
        
    protected
      
      def list_rows(start,final,day_width)
        @rows.inject('') do |html,row|
          row_width = (final - start) * day_width
          html << "<div class='row' style='width: #{row_width}px; z-index:50'>"
          html << list_periods(row,start,day_width)
          html << "</div>"
          html
        end.html_safe
      end

      def list_periods(row,start,day_width)
        row.inject('') do |html, task_list|
          task_list_width = task_list.length * day_width
          task_list_offset = (task_list.start - start) * day_width + @offset
          html << %(<div class='task_list #{task_list.classes}' style='width: #{task_list_width}px; left: #{task_list_offset}px'>)
          html << %(<a href="#{task_list.link}">#{task_list}</a>)
          html << %(</div>)
          html
        end.html_safe
      end
      
      def add_to_rows(task_list)
        # Tries to fit the task_list in the best possible row
        unless @expanded
          @rows.each do |row|
            unless row.detect { |existing_task_list| task_list.overlaps? existing_task_list }
              # If no overlap is detected, we can add it to this row
              row << task_list
              return
            end
          end
        end
      
        @rows << [task_list] # If no rows were suitable, a new one must be created
      end
  end
end