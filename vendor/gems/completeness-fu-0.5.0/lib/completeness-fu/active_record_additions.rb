module CompletenessFu
  
  class << self
    attr_accessor :common_weightings
    attr_accessor :default_weighting
    attr_accessor :default_i18n_namespace
    attr_accessor :default_grading
  end
    
  
  module ActiveRecordAdditions
    
    def self.included(base)
      base.class_eval do
        def self.define_completeness_scoring(&checks_block)
          class_inheritable_array :completeness_checks
          cattr_accessor :default_weighting
          cattr_accessor :model_weightings
          
          self.send :extend, ClassMethods
          self.send :include, InstanceMethods
          
          checks_results = CompletenessFu::ScoringBuilder.generate(self, &checks_block)
          
          self.default_weighting   = checks_results[:default_weighting]
          self.completeness_checks = checks_results[:completeness_checks]
          self.model_weightings    = checks_results[:model_weightings]
          self.before_validation checks_results[:cache_score_details] if checks_results[:cache_score_details]
        end
      end
    end
    
    
    module ClassMethods
      def max_completeness_score
        self.completeness_checks.inject(0) { |score, check| score += check[:weighting].to_f }
      end
    end
    
    
    module InstanceMethods
      # returns an array of hashes with the translated name, description + weighting
      def failed_checks
        self.completeness_checks.inject([]) do |failures, check| 
          failures << translate_check_details(check) if not check[:check].call(self)
          failures
        end
      end
      
      # returns an array of hashes with the translated name, description + weighting
      def passed_checks
        self.completeness_checks.inject([]) do |passed, check| 
          case check[:check]
          when Proc
            passed << translate_check_details(check) if check[:check].call(self)
          when Symbol
            passed << translate_check_details(check) if self.send check[:check]
          end
          
          passed
        end
      end
      
      # returns the absolute complete score
      def completeness_score
        sum_score = 0
        passed_checks.each { |check| sum_score += check[:weighting] }
        sum_score
      end
      
      # returns the percentage of completeness (relative score)
      def percent_complete
        self.completeness_score.to_f / self.class.max_completeness_score.to_f  * 100
      end
      
      #returns next_failed_check
      def next_failed_check
        self.failed_checks.first
      end
      
      #returns the perctenage of next possible completeness
      def next_percent_complete
        (self.completeness_score.to_f + self.failed_checks.first[:weighting]) / self.class.max_completeness_score.to_f  * 100
      end
      
      # returns a basic 'grading' based on percent_complete, defaults are :high, :medium, :low, and :poor
      def completeness_grade
        CompletenessFu.default_grading.each do |grading| 
          return grading.first if grading.last.include?(self.percent_complete) 
        end
      end
      
      
      private 
      
        def translate_check_details(full_check)
          namespace = CompletenessFu.default_i18n_namespace + [self.class.name.downcase.to_sym, full_check[:weight_grade]]
          
          translations = [:title, :description, :extra].inject({}) do |list, field|
                           list[field] = I18n.t(field.to_sym, :scope => namespace)
                           list
                         end
          
          full_check.merge(translations)
        end
        
        def cache_completeness_score(score_type)
          score = case score_type
                  when :relative
                    self.percent_complete
                  when :absolute
                    self.completeness_score
                  else
                    raise ArgumentException, 'completeness scoring type not recognized'
                  end
          self.cached_completeness_score = score.round
        end
    end
    
  end
  
end