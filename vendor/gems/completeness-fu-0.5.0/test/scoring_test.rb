# encoding: utf-8
require 'test/helper'


class ScoringTest < Test::Unit::TestCase
  
  context "An ActiveRecord child class" do
    should "have a define_completeness_scoring mixed in" do
      reset_class 'ScoringTest'
      assert ScoringTest.methods.include?('define_completeness_scoring')
    end
  end
  
  
  context "A class with scoring defined" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          check :title, lambda { |test| test.title.present? }, 20
        end
      end
    end
    
    should "have one scoring check" do
      assert_equal 1, ScoringTest.completeness_checks.size
    end
  
    should "have one failed check" do
      st = ScoringTest.new
      assert_equal 1, st.failed_checks.size
    end
  
  
    context "and with one complete check" do
      setup do
        @st = ScoringTest.new
        @st.title = 'I have a title'
      end
      
      should "have an absolute completeness score of 20" do
        assert_equal 20, @st.completeness_score
      end
    
      should "have a relative completeness score of 0 (percent complete)" do
        assert_equal 100, @st.percent_complete
      end
      
      should "have a description" do
        assert_equal "The Scoring Test Description", @st.passed_checks.first[:description]
      end
    end
  end
  
  
  context "A class with scoring defined with no weighting" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          check :title, lambda { |test| test.title.present? }
        end
      end
      @st = ScoringTest.new
      @st.title = 'I have a title'
    end
    
    should "have the default scoring used" do
      assert_equal 40, @st.completeness_score
    end
  end


  context "A class with scoring defined with a symbol weighting" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          check :title, lambda { |test| test.title.present? }, :high
        end
      end
      @st = ScoringTest.new
      @st.title = 'I have a title'
    end
    
    should "have a scoring from the common_weightings hash used used" do
      assert_equal ScoringTest.model_weightings[:high], @st.completeness_score
    end
  end
  
  
  context "A class with scoring defined with a custom weighting" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          weightings :super_high => 80
          check :title, lambda { |test| test.title.present? }, :super_high
        end
      end
      @st = ScoringTest.new
      @st.title = 'I have a title'
    end
    
    should "have a scoring from the common_weightings hash used used" do
      assert_equal ScoringTest.model_weightings[:super_high], @st.completeness_score
    end
  end
  
  
  context "A class with scoring defined with a custom weighting and no common weightings" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          weightings :super_high => 80 , :merge_with_common => false
          check :title, lambda { |test| test.title.present? }, :super_high
        end
      end
      @st = ScoringTest.new
      @st.title = 'I have a title'
    end
    
    should "have a scoring from the common_weightings hash used used" do
      assert_equal nil, ScoringTest.model_weightings[:high]
      assert_equal ScoringTest.model_weightings[:super_high], @st.completeness_score
    end
  end
  
  
  context "A class with scoring defined with a check using a symbol to a private method" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          check :title, :title_present?, :high
        end
        
        private
          def title_present?
            self.title.present?
          end
      end
      @st = ScoringTest.new
      @st.title = 'I have a title'
    end
    
    should "have a scoring from the common_weightings hash used used" do
      assert_equal 1, @st.passed_checks.size
      assert_equal 60, @st.completeness_score
    end
  end
  
  
  context "A class with scoring defined and cache to field directive" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          cache_score :absolute
          check :title, :title_present?, :high
        end
        
        private
          def title_present?
            self.title.present?
          end
      end
      @st = ScoringTest.new
      @st.title = 'I have a title'
    end
    
    should "have a before filter added, and save the defined calculation to the default field" do
      assert_equal nil, @st.cached_completeness_score
      @st.valid?
      assert_equal @st.completeness_score, @st.cached_completeness_score
    end
  end
  
  
  context "A class with scoring" do
    setup do
      reset_class 'ScoringTest'
      ScoringTest.class_eval do
        define_completeness_scoring do
          check :title, lambda { |test| test.title.present? }, :high
        end
      end
      @st = ScoringTest.new
    end
    
    should "have a grade of :high" do
      assert_equal :poor, @st.completeness_grade
      @st.title = 'I have a title'
      assert_equal :high, @st.completeness_grade
    end
  end
end