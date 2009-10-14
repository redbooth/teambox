ActiveRecord::Schema.define :version => 0 do
  create_table "scoring_tests", :force => true do |t|
    t.string :title
    t.string :cached_completeness_score
  end
end
