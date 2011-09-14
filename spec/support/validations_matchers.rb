module RSpec
  module Rails
    module Matchers

      RSpec::Matchers.define :validate_presence_of do |attribute|
        match do |model|
          model.send("#{attribute}=", nil)
          !model.valid? && model.errors[attribute].any?
        end
        description do
          "model to validate the presence of #{attribute}"
        end
      end

      RSpec::Matchers.define :validate_length_of do |attribute, options|
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
        match do |model|
          invalid = false
          if !min.nil? && min >= 1
            model.send("#{attribute}=", 'a' * (min - 1))
            invalid = !model.valid? && model.errors[attribute].any?
          end

          if !max.nil?
            model.send("#{attribute}=", 'a' * (max + 1))
            invalid ||= !model.valid? && model.errors[attribute].any?
          end
          invalid
        end
        description do
          "model to validate the length of #{attribute} within #{min || 0} and #{max || 'Infinity'}"
        end
      end

      RSpec::Matchers.define :validate_uniqueness_of do |attribute|
        match do |model|
          model.class.stub!(:find).and_return(true)
          !model.valid? && model.errors[attribute].any?
        end
        description do
          "model to validate the uniqueness of #{attribute}"
        end
      end

      RSpec::Matchers.define :validate_confirmation_of do |attribute|
        match do |model|
          model.send("#{attribute}_confirmation=", 'asdf')
          !model.valid? && model.errors[attribute].any?
        end
        description do
          "model to validate the confirmation of #{attribute}"
        end
      end

    end
  end
end