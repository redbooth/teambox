module GanttChart
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
      "<div class='ruler'>#{html}</div>"
    end

    def to_html(day_width=30, margin=50, expanded=true)
      @expanded = expanded
      
      return if !@rows or @rows.empty?
      html = ruler_to_html(@final-@start,day_width)
      html << list_rows(@start,@final,day_width)
      html
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
        next if !task_list.start && !task_list.final
        task_list.start = start if !task_list.start || task_list.start < start
        task_list.final = final if !task_list.final || task_list.final > final
        next if task_list.start > final
        next if task_list.final < start

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
        end
      end

      def list_periods(row,start,day_width)
        row.inject('') do |html, task_list|
          task_list_width = task_list.length * day_width
          task_list_offset = (task_list.start - start) * day_width + @offset
          html << "<div class='task_list' style='width: #{task_list_width}px; left: #{task_list_offset}px'>#{task_list}</div>"
          html
        end
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