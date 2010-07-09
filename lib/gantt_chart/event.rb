module GanttChart
  class Event
    attr_accessor :start, :final, :description

    def initialize(start, final, description = nil)
      @start = set_destination(start)
      @final = set_destination(final)
      @description = description || [@start,@final].join('-')
    end

    # Checks if two events overlap in time
    def overlaps?(task_list)
      ((task_list.start < self.final && self.final <= task_list.final) ||
        (self.start < task_list.final && task_list.final <= self.final))
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
end  