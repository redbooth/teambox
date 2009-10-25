module Spec
  module Rails
    module Matchers
      def validate_presence_of(attribute)
        return simple_matcher("model to validate the presence of #{attribute}") do |model|
          model.send("#{attribute}=", nil)
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_length_of(attribute, options)
        if options.has_key? :within
          min = options[:within].first
          max = options[:within].last
        elsif options.has_key? :is
          min = options[:is]
          max = min
        elsif options.has_key? :minimum
          min = options[:minimum]
        elsif options.has_key? :maximum
          max = options[:maximum]
        end
        
        return simple_matcher("model to validate the length of #{attribute} within #{min || 0} and #{max || 'Infinity'}") do |model|
          invalid = false
          if !min.nil? && min >= 1
            model.send("#{attribute}=", 'a' * (min - 1))

            invalid = !model.valid? && model.errors.invalid?(attribute)
          end
          
          if !max.nil?
            model.send("#{attribute}=", 'a' * (max + 1))

            invalid ||= !model.valid? && model.errors.invalid?(attribute)
          end
          invalid
        end
      end

      def validate_uniqueness_of(attribute)
        return simple_matcher("model to validate the uniqueness of #{attribute}") do |model|
          model.class.stub!(:find).and_return(true)
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_confirmation_of(attribute)
        return simple_matcher("model to validate the confirmation of #{attribute}") do |model|
          model.send("#{attribute}_confirmation=", 'asdf')
          !model.valid? && model.errors.invalid?(attribute)
        end
      end
    end
  end
end