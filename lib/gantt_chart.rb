# Builds a GANTT Chart from the given array of tasks
# It'll need some CSS to display well, for example:
#
# .gantt { margin: 20px; }
#   .row { position: relative; display: block; margin-bottom: 2px; border: 1px solid #aaa; background: #aaa; width: 600px; height: 22px; }
#   .task { position: absolute; border: 1px solid #000; background: #5f5; height: 20px; white-space: nowrap; overflow: hidden; cursor: move; }

module GanttChart

  class Event
    attr_accessor :start, :final, :description

    def initialize(start, final, description = nil)
      tommorrow = Time.current.to_date + 1.day
      if start.is_a? Date
        @start = (start - tommorrow).to_i
      elsif start.is_a? Fixnum
        @start = start
      elsif start.is_a? NilClass
        @start = nil
      else
        puts start
        raise "Invalid start date"
      end
      if final.is_a? Date
        @final = (final - tommorrow).to_i
      elsif final.is_a? Fixnum
        @final = final
      elsif final.is_a? NilClass
        @final = nil
      else
        raise "Invalid final date"
      end
      @description = description || "#{@start || ''}-#{@final || ''}"
    end

    # Checks if two events overlap in time
    def overlaps?(task)
      return true if task.start < self.final and self.final <= task.final
      return true if self.start < task.final and task.final <= self.final
      return false
    end

    def length
      final - start
    end

    def to_s
      @description
    end
  end

  class Base
    attr_accessor :tasks, :rows

    def initialize(tasks=nil)
      @tasks = tasks
      
      # If no args are passed, load default data set
      if tasks.nil?
        @tasks = []
        @tasks << Event.new(2, 9)
        @tasks << Event.new(1, 3)
        @tasks << Event.new(1, 9)
        @tasks << Event.new(1, 5)
        @tasks << Event.new(2, 5)
        @tasks << Event.new(7, 9)
        @tasks << Event.new(1, 3)
        @tasks << Event.new(4, 9)
        @tasks << Event.new(7, 8)
        @tasks << Event.new(0, 3)
        @tasks << Event.new(5, 20)
        @tasks << Event.new(15, 20)
        @tasks << Event.new(0, 20)
        @tasks << Event.new(4, 5)
      end
    end

    def to_text(start=1, final=10)
      process start, final if @rows.nil?

      text = ''
      i = 0
      @rows.each do |row|
        text << '-' * (row.first.start - start)
        last_ended = nil
        row.each do |task|
          text << '-' * (task.start - last_ended) unless last_ended.nil?
          text << i.to_s * task.length
          last_ended = task.final
          i += 1
        end
        text << '-' * (final - row.last.final)
        text << "\n"
      end
      return text
    end

    def ruler_to_html(days,day_width)
      html = ''
      html << '<div class="ruler">'
      (0..days).each do |i|
        date = Time.current + i.day
          default = 10
          five_spaces =  (i*day_width - (date.day > 9 ? 5 : 1) + default).to_s + 'px;'
          ten_spaces  =  (i*day_width - (date.day == 1 ? 10 : 0)+ default).to_s + 'px;'
          add_weight = date.wday == 1 ? 'font-weight:bold; color: rgb(100,100,100)' : ''
          date_display = date.day == 1 ? Date::ABBR_MONTHNAMES[date.month] : date.day.to_s          
          html << "<div class='date' style='left: #{five_spaces} #{add_weight}'>#{date_display}</div>"
          html << "<div class='mark' style='left: #{ten_spaces}'></div>"
        end
      html << '</div>'
      return html
    end

    def to_html(start=1, final=10, day_width=30, margin=50, ruler=true, expanded=true)
      @expanded = expanded
      process start, final

      return if !@rows or @rows.empty?
      default = 10
      html = ''
      html << ruler_to_html(final-start,day_width) if ruler
      @rows.each do |row|
        html << "<div class='row' style='width: #{(final-start)*day_width+1}px;'>"
        last_ended = nil
        row.each do |task|
          html << "<div class='task' style='width: #{task.length * day_width+1}px; left: #{(task.start - start) * day_width+default}px'>#{task}</div>"
          last_ended = task.final
        end
        html << '</div>'
      end
      return html
    end

    protected

    def add_to_rows(task)
      # Tries to fit the task in the best possible row
      unless @expanded
        @rows.each do |row|
          unless row.detect { |existing_task| task.overlaps? existing_task }
            # If no overlap is detected, we can add it to this row
            row << task
            return
          end
        end
      end
      # If no rows were suitable, a new one must be created
      @rows << [task]
    end
    
    def process(start, final)
      @rows = []

      @tasks.sort! do |a,b|
        if !a.start
          -1
        elsif !b.start
          1
        else
          a.start <=> b.start
        end
      end
      @tasks.each do |task|
        # Clip the task to the given time window
        next if !task.start && !task.final
        task.start = start if !task.start || task.start < start
        task.final = final if !task.final || task.final > final
        next if task.start > final
        next if task.final < start

        add_to_rows task
      end
    end
  end
end