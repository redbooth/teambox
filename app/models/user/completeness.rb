class User
  
  define_completeness_scoring do
    check :biography, lambda { |per| per.biography.present? },    :biography_presence
    check :biography, lambda { |per| per.biography.length > 10 }, :biography_length_short
    check :biography, lambda { |per| per.biography.length > 20 }, :biography_length_average
    check :biography, lambda { |per| per.biography.length > 30 }, :biography_length_long
  end
  
  def profile_complete?
    true
    # Profile completeness is disabled temporarily
    # completeness_score == 100
  end

  def update_profile_score
    self.profile_score   = self.completeness_score
    self.profile_percent = self.percent_complete
    self.profile_grade   = self.completeness_grade.to_s
  end

end