module Spec
  module Rails
    module Matchers

      class Observe
        def initialize(expected_model_class)
          @expected_model_class = expected_model_class
        end
    
        def matches?(observer)
          @observer = observer
          if @observer.is_a?(ActiveRecord::Observer)
            @observer = @observer.class
          end
          @observed_classes = observer.observed_classes.flatten
          @observed_classes.include?(@expected_model_class)
        end
    
        def failure_message
          return "expected #{@observer.name} to observe #{@expected_model_class.name}, but it was not included in [#{@observed_classes.map(&:name).join(', ')}]"
        end
    
        def description
          "observer to be observing #{@expected_model_class.name}"
        end
      end

      def observe(expected_model_class)
        Observe.new(expected_model_class)
      end
      
    end
  end
end