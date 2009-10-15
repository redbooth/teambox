require 'completeness-fu/active_record_additions'
require 'completeness-fu/scoring_builder'

module ActiveRecord
  Base.class_eval do
    include CompletenessFu::ActiveRecordAdditions
  end
end


CompletenessFu.common_weightings  = { :low => 20, :medium => 40, :high => 60 }

CompletenessFu.default_weighting = :low

CompletenessFu.default_i18n_namespace = [:completeness_scoring, :models]

CompletenessFu.default_grading    = { :poor => 0..24, 
                                      :low =>  25..49, 
                                      :medium => 50..79, 
                                      :high => 80..100 }