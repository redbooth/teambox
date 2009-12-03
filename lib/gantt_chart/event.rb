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
      return true if task_list.start < self.final and self.final <= task_list.final
      return true if self.start < task_list.final and task_list.final <= self.final
      return false
    end

    def length
      final - start
    end

    def to_s
      @description
    end

    def set_destination(position)
      tommorrow = Time.current.to_date + 1.day
      case position.class.to_s
        when 'Date'
          (position - tommorrow).to_i
        when 'Fixnum'
          position
        when 'NilClass'
          nil
        else
          raise "Invalid date"
      end
    end 

  end
end  